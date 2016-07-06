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

private let alphabet = "abcdefghijklmnopqrstuvwxyz"

class PythonFunctionBridge {
    private var engine: PythonMacroEngine?
    
    private var pythonFunctions: [String: PythonFunction] = [:]
    
    init(engine: PythonMacroEngine) {
        self.engine = engine
        
        setupHook()
    }
    
    
    func registerFunction(function: PythonFunction) -> Bool {
        var ret = false
        
        if pythonFunctions[function.name] == nil {
            pythonFunctions[function.name] = function
            
            let prototype = prototypeString(function)
            let script = PythonScript(name: function.name, python: prototype, location: .Memory)
            script.run(engine!)
            
            ret = true
        }
        
        return ret
    }
    
    
    private func setupHook() {
        ios_process_block = { py_obj -> UnsafeMutablePointer<PyObject> in
            let (oname, tuple) = self.parseArgs(py_obj)
            guard let name = oname where tuple != nil else {
                PyErr_SetString(PyExc_TypeError, "Called with wrong parameters")
                return nil
            }

            if let f = self.pythonFunctions[name] {
                let args = f.parseArgs(tuple)

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
    
    
    private func parseArgs(args: UnsafeMutablePointer<PyObject>) -> (String?, UnsafeMutablePointer<PyObject>) {
        let buffer: UnsafeMutablePointer<UnsafeMutablePointer<Int8>> = UnsafeMutablePointer<UnsafeMutablePointer<Int8>>.alloc(1)
        let tuple: UnsafeMutablePointer<UnsafeMutablePointer<PyObject>> = UnsafeMutablePointer<UnsafeMutablePointer<PyObject>>.alloc(1)
        let va_list: [CVarArgType] = [buffer, tuple]
        
        let ret = withVaList(va_list) { p -> (String?, UnsafeMutablePointer<PyObject>) in
            if PyArg_VaParse(args, "s|O", p) != 0 {
                return (String(UTF8String: buffer.memory), tuple.memory)
            }

            return (nil, nil)
        }
        
        return ret
    }
    
    
    private func prototypeString(function: PythonFunction) -> String {
        let argNames: [String] = generateArgNames(function.callArgs.count)
        let argTypes: [String] = generateArgTypes(function.callArgs)
        let retType: String? = pythonType(function.returnType)

        var a: [String] = []
        for i in 0..<argNames.count {
            a.append("\(argNames[i]): \(argTypes[i])")
        }
        
        var def: String = "def \(function.name)(\(a.joinWithSeparator(", ")))"
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
    
    
    private func generateArgNames(numArgs: Int) -> [String] {
        var ret: [String] = []
        
        var index = alphabet.characters.startIndex
        for _ in 0..<numArgs {
            ret.append(String(alphabet.characters[index]))
            index = index.successor()
        }
        
        return ret
    }
    
    
    private func generateArgTypes(args: [PythonFunction.PythonTypes]) -> [String] {
        var ret: [String] = []
        
        for arg in args {
            ret.append(pythonType(arg)!)
        }
        
        return ret
    }
    
    
    private func pythonType(type: PythonFunction.PythonTypes) -> String? {
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