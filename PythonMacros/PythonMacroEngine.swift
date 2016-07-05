//
// PythonMacroEngine.swift
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

// Javascript callbacks for getting/setting outerProgress
private let myBlock: @convention(block) Float -> Float = { newValue in
    print(newValue)
    
    return 33.3
}

class PythonMacroEngine {

    static let sharedInstance: PythonMacroEngine = PythonMacroEngine()
    
    var output: PythonCaptureOutput?
    var error: PythonErrorMonitor?

    private var mainModule: PythonObject!
    var callable: PythonFunctionBridge?

    init() {
        setupExtensions()
        setupHome()

        Py_Initialize()

        PyEval_InitThreads();
        

        setupPath()
        setupMain()
        
        output = PythonCaptureOutput(module: mainModule, engine: self)
        error = PythonErrorMonitor(engine: self)

        setupFunctionBridge()
    }


    deinit {
        mainModule = nil
        output = nil
        Py_Finalize()
    }

    
    func run(script: String) {
        PyRun_SimpleStringFlags(script, nil)
     
        output?.refreshOutput()
        error?.checkError()
    }
    
    
    func lookupObject(objectName: String) -> PythonObject? {
        guard let mm = mainModule else { return nil }
        
        let p = PyObject_GetAttrString(mm.object, objectName)
        
        return PythonObject(object: p)
    }

    
    private func setupExtensions() {
        init_ios_module()
    }


    private func setupHome() {
        let resourcePath = NSBundle.mainBundle().resourcePath!

        let pythonResources = "\(resourcePath)/Library/Python.framework/Resources"
        let wpython_home = _Py_char2wchar(pythonResources, nil)
        Py_SetPythonHome(wpython_home);
    }


    private func setupPath() {
        let resourcePath = NSBundle.mainBundle().resourcePath!

        let wpath = Py_GetPath()
        let c = _Py_wchar2char(wpath, nil)
        let path = String(UTF8String: c)!

        let newPath = "\(path):\(resourcePath)"
        let wpythonPath = _Py_char2wchar(newPath, nil)
        PySys_SetPath(wpythonPath)
    }
    
    private func setupMain() {
        let module = PyImport_AddModule("__main__")
        mainModule = PythonObject(object: module)
        Py_DecRef(module)
    }
    
    
    private func setupFunctionBridge() {
        callable = PythonFunctionBridge(engine: self)
        
        // Test Bridge
        let f = PythonFunction(name: "Hello", callArgs: [.String, .Float, .Float], returnType: .Float) { args -> AnyObject? in
            print(args)
            return 2.2
        }
        callable?.registerFunction(f)
    }
}


extension PythonMacroEngine: CustomStringConvertible, CustomDebugStringConvertible {
    var description: String {
        return customDescription()
    }
    
    
    var debugDescription: String {
        return customDescription()
    }
    
    
    private func customDescription() -> String {
        return "PythonMacroEngine(\(self))"
    }
}
