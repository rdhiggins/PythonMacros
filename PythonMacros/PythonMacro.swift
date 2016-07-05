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


class PythonMacro {
    let script: PythonScript?
    let functionName: String?
    var object: PythonObject?
    
    init(filename: String, functionName: String) {
        self.functionName = functionName
        script = PythonScript.loadResourceScript(filename)

        setupMacro()
    }
    
    private func setupMacro() {
        guard let script = self.script,
            name = functionName else { return }
        
        script.run()
        
        object = PythonMacroEngine.sharedInstance.lookupObject(name)
    }
    
    
    private func buildArgumentsString(args: [CVarArgType]) -> String {
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
    
    private func call_va(args: [CVarArgType]) -> PythonObject {
        var rv: UnsafeMutablePointer<PyObject> = nil
        
        withVaList(args) { p in
            let a = Py_VaBuildValue(buildArgumentsString(args), p)
            
            rv = PyEval_CallObjectWithKeywords(object!.object, a, nil)
            Py_DecRef(a)
        }
        
        return PythonObject(object: rv)
    }

    func call(args: CVarArgType...) {
        self.call_va(args)
    }
    
    func call(args: CVarArgType...) -> Double {
        return self.call_va(args).toDouble()
    }
    
    func call(args: CVarArgType...) -> Float {
        return self.call_va(args).toFloat()
    }
    
    func call(args: CVarArgType...) -> String? {
        return self.call_va(args).toString()
    }
    
    func call(args: CVarArgType...) -> Int {
        return self.call_va(args).toInt()
    }
}


