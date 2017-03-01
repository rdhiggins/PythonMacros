//
// PythonCallableFunctions.swift
// MIT License
//
// Copyright (c) 2016 Spazstik Software, LLC
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.


import Foundation


// used to generate parameter names in python
private let alphabet = "abcdefghijklmnopqrstuvwxyz"


/// A class used to manage the functionality for calling swift blocks from
/// python.  This class is initiated by the PythonMacroEngine object.
///
/// This class facilitates the calling of swift blocks by handling the
/// convertion of parameters and return types.
///
/// This class relies upon the custom module defined in the objective-c ios.m/.h
/// files.  This module provides a single function such that a callable swift
/// block is defined the __main__ module like so:
///
/// def functionName(a: type1, b: type2, ...) -> returnType:
///     return call('functionName',(a,b...))
///
class PythonFunctionBridge {
    fileprivate var engine: PythonMacroEngine?
    
    fileprivate var pythonFunctions: [String: PythonFunction] = [:]
    
    init(engine: PythonMacroEngine) {
        self.engine = engine
        
        setupHook()
    }
    

    /// A public method used to register a swift block as a python function
    /// loaded into the CPython runtime.  This method essentially generates
    /// a python script defining a function that is called from python.  The
    /// function calls the custom ios module with the block name and a tuple
    /// containing the parameters.  These are converted to swift, the block is
    /// called, and the return value is passed back to the CPython runtime.
    ///
    /// - parameter function: A PythonFunction reference to register.
    /// - returns: A bool indicating a success
    func registerFunction(_ function: PythonFunction) -> Bool {
        var ret = false
        
        if pythonFunctions[function.name] == nil {
            pythonFunctions[function.name] = function
            
            let prototype = prototypeString(function)
            let script = PythonScript(name: function.name, python: prototype, location: .memory)
            _ = script.run(engine!)
            
            ret = true
        }
        
        return ret
    }
    
    
    /// A private method used to register a block into the global variable
    /// defined in the ios python module.  This block performs the steps
    /// necessary for the block to be called with the proper parameters and
    /// return the required value.
    fileprivate func setupHook() {
        ios_process_block = { py_obj -> UnsafeMutablePointer<PyObject>? in
            let (oname, tuple) = self.parseArgs(py_obj!)
            guard let name = oname, tuple != nil else {
                PyErr_SetString(PyExc_TypeError, "Called with wrong parameters")
                return nil
            }

            if let f = self.pythonFunctions[name] {
                let args = f.parseArgs(tuple!)

                if args.count == f.callArgs.count {
                    let rv = f.call(args)
                    return f.encodeReturn(rv)
                }
            } else {
                PyErr_SetString(PyExc_TypeError, "Matching block not found")
            }

            return nil
        }
    }
    
    
    /// A private method used to parse the PyObject arguments passed from
    /// the CPython runtime that are expected to be handed to the registered
    /// swift block.
    ///
    /// - parameters args: A UnsafeMutablePointer<PyObject> of the arguments
    /// passed to the swift block from CPthon
    /// - returns: A swift tuple that contains the name of the swift block
    /// and another UnsafeMutablePointer<PyObject> to the python tuple
    /// containing the arguments for the swift block
    fileprivate func parseArgs(_ args: UnsafeMutablePointer<PyObject>) -> (String?, UnsafeMutablePointer<PyObject>?) {
        let buffer: UnsafeMutablePointer<UnsafeMutablePointer<Int8>> = UnsafeMutablePointer<UnsafeMutablePointer<Int8>>.allocate(capacity: 1)
        let tuple: UnsafeMutablePointer<UnsafeMutablePointer<PyObject>> = UnsafeMutablePointer<UnsafeMutablePointer<PyObject>>.allocate(capacity: 1)
        let va_list: [CVarArg] = [buffer, tuple]
        
        let ret = withVaList(va_list) { p -> (String?, UnsafeMutablePointer<PyObject>?) in
            if PyArg_VaParse(args, "s|O", p) != 0 {
                return (String(validatingUTF8: buffer.pointee), tuple.pointee)
            }

            return (nil, nil)
        }
        
        return ret
    }
    
    
    /// A private method used to generate the python function definition 
    /// that is loaded into python that represents the swift block that is
    /// being registered.
    ///
    /// - parameter function: A PythonFunction reference to generate the
    /// prototype for.
    /// - returns: A python script that defines the function for the swift
    /// block.
    fileprivate func prototypeString(_ function: PythonFunction) -> String {
        let argNames: [String] = generateArgNames(function.callArgs.count)
        let argTypes: [String] = generateArgTypes(function.callArgs)
        let retType: String? = pythonType(function.returnType)

        var a: [String] = []
        for i in 0..<argNames.count {
            a.append("\(argNames[i]): \(argTypes[i])")
        }
        
        var def: String = "def \(function.name)(\(a.joined(separator: ", ")))"
        var body: String = "ios.call('\(function.name)', ("
        for an in argNames {
            body += "\(an), "
        }
        body += "))\n"
        
        if retType != nil {
            def += " -> \(retType!):\n"
            body = "    return " + body
        } else {
            def += ":\n"
            body = "    " + body
        }

        let prototype: String = "import ios\n\(def)\(body)"
        
        return prototype
    }
    
    
    /// A private method used to generate the list of argument names
    ///
    /// - parameter numArgs:  Number of arguments for the function
    /// - returns: Array of strings that contain a argument name for
    /// each argument.
    fileprivate func generateArgNames(_ numArgs: Int) -> [String] {
        var ret: [String] = []
        
        var index = alphabet.characters.startIndex
        for _ in 0..<numArgs {
            ret.append(String(alphabet.characters[index]))
            index = alphabet.characters.index(after: index)
        }
        
        return ret
    }
    
    
    /// A private method used to generate a list of the argument types
    ///
    /// - parameters args: Array of the PythonTypes for the arguments for the
    /// function
    /// - returns Array of strings containing the types to use for the
    /// functions argument.
    fileprivate func generateArgTypes(_ args: [PythonFunction.PythonTypes]) -> [String] {
        var ret: [String] = []
        
        for arg in args {
            ret.append(pythonType(arg)!)
        }
        
        return ret
    }
    
    
    /// A private method used to convert a PythonTypes enum to a string.
    fileprivate func pythonType(_ type: PythonFunction.PythonTypes) -> String? {
        switch type {
        case .Float, .Double:
            return "float"
        case .Long:
            return "long"
        case .Int:
            return "int"
        case .String:
            return "str"
        case .Void:
            return nil
        }
    }
}
