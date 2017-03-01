//
// PythonMacro.swift
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

/// The class that manages a Python macro function.  This is a python
/// function that is called from swift.  This supports variable parameters
/// and different return types.
///
/// Only works with PythonScripts that are part of the application's resource
/// bundle
class PythonMacro {
    
    /// Property containing the reference to the PythonScript object that
    /// is python function for this macro
    let script: PythonScript?
    
    
    /// Property containing the name of the python function.
    let functionName: String?
    
    
    /// Property containing a PythonObject reference to the loaded PyObject
    /// for this macro
    var object: PythonObject?
    
    
    /// Initialization method.
    ///
    /// - parameter filename: The filename of the resource script
    /// - parameter functionName: The python functionName
    init(filename: String, functionName: String) {
        self.functionName = functionName
        
        script = PythonScript.loadResourceScript(filename)

        setupMacro()
    }
    
    
    /// A private method used to load the macro into the CPython
    /// runtime.  It also store a reference to the loaded PyObject
    /// for the macro
    fileprivate func setupMacro() {
        guard let script = self.script,
            let name = functionName else { return }
        
        _ = script.run()
        
        object = PythonMacroEngine.sharedInstance.lookupObject(name)
    }
    
    
    /// A public method used to reload the python macro into the CPython
    /// environment.  Use this method to update the macro when the python
    /// script has changed.
    func registerMacro() {
        setupMacro()
    }
    
    
    /// A private method used to construct the list of argument types.
    /// This is needed in the call to the CPython environment to execute
    /// the macro.
    ///
    /// - parameters args: A CVarArgType array of the arguments to pass
    /// to the macro.
    fileprivate func buildArgumentsString(_ args: [CVarArg]) -> String {
        var ret = "("
        
        for arg in args {
        
            if let _ = arg as? Float {
                ret += "f"
            } else if let _ = arg as? Double {
                ret += "d"
            } else if let _ = arg as? String {
                ret += "s"
            } else if let _ = arg as? Int64 {
                ret += "l"
            } else if let _ = arg as? Int {
                ret += "i"
            }
        }
        
        return ret + ")"
    }
    
    
    /// A private method that performs the call to the python macro.
    ///
    /// - parameter args: A CVarArgType array of the arguments to pass
    /// to the python macro
    fileprivate func call_va(_ args: [CVarArg]) -> PythonObject {
        var rv: UnsafeMutablePointer<PyObject>? = nil
        
        withVaList(args) { p in
            let a = Py_VaBuildValue(buildArgumentsString(args), p)
            
            rv = PyEval_CallObjectWithKeywords(object!.object, a, nil)
            Py_DecRef(a)
        }

        PythonMacroEngine.sharedInstance.checkEngineStatus()
        return PythonObject(object: rv!)
    }

    
    /// A public method used to a python macro that does not return anything.
    ///
    /// - parameter args: A CVarArgType array of the arguments to pass
    /// to the python macro
    func call(_ args: CVarArg...) {
        _ = self.call_va(args)
    }

    
    /// A public method used to a python macro that returns a Double.
    ///
    /// - parameter args: A CVarArgType array of the arguments to pass
    /// to the python macro
    /// - returns: A double from the python macro
    func call(_ args: CVarArg...) -> Double {
        return self.call_va(args).toDouble()
    }
    
    
    /// A public method used to a python macro that returns a Float.
    ///
    /// - parameter args: A CVarArgType array of the arguments to pass
    /// to the python macro
    /// - returns: A Float from the python macro
    func call(_ args: CVarArg...) -> Float {
        return self.call_va(args).toFloat()
    }
    
    
    /// A public method used to a python macro that returns a optional string.
    ///
    /// - parameter args: A CVarArgType array of the arguments to pass
    /// to the python macro
    /// - returns: A optional string from the python macro
    func call(_ args: CVarArg...) -> String? {
        return self.call_va(args).toString()
    }
    
    
    /// A public method used to a python macro that returns a Int.
    ///
    /// - parameter args: A CVarArgType array of the arguments to pass
    /// to the python macro
    /// - returns: A Double from the python macro
    func call(_ args: CVarArg...) -> Int {
        return self.call_va(args).toInt()
    }
}


