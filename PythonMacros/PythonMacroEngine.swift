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


/// Class used to interface with the CPython runtime.  Interaction is thru a
/// shared public instance.
class PythonMacroEngine {

    /// Class property used to return the global instance object.
    static let sharedInstance: PythonMacroEngine = PythonMacroEngine()
    
    /// Property that contains the standard out and standard error streams
    /// from CPython.
    var output: PythonCaptureOutput?
    
    
    /// Property that contains the object that monitors CPython for error.
    var error: PythonErrorMonitor?

    
    /// A private property that contains the ref to the __main__ module
    /// object.  This is used to lookup objects that are loaded into the
    /// runtime.
    private var mainModule: PythonObject!
    
    
    /// Property that references the object that bridges swift blocks to
    /// CPython.
    var callable: PythonFunctionBridge?

    
    /// Initialization method.  Currently sets up the CPython runtime and
    /// activates it.
    init() {
        // Register custom modules and setup CPython home directory
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
        
        Py_Finalize()       // Close down CPython
    }

    
    /// A method used to execute a Python script in CPython.
    ///
    /// - parameter script:   The Python script to execute
    func run(script: String) {
        PyRun_SimpleStringFlags(script, nil)

        checkEngineStatus()
    }
    
    
    /// A method that is called after an operation to check for errors and
    /// stream output
    func checkEngineStatus() {
        output?.refreshOutput()
        error?.checkError()
    }
    
    
    /// Method used to lookup a Python object in the __main__ module.
    ///
    /// - parameter objectName: String containing the Python objects name
    func lookupObject(objectName: String) -> PythonObject? {
        guard let mm = mainModule else { return nil }
        
        let p = PyObject_GetAttrString(mm.object, objectName)
        
        return PythonObject(object: p)
    }

    
    /// A private method used to register custom modules with CPython.
    private func setupExtensions() {
        init_ios_module()
    }


    /// A private method used to inform CPython where its resources are located.
    /// This is currently the application bundle.  The big ticket item is a zip
    /// file containing the modules that CPython needs.  This is setup through
    /// a custom puild phace script.
    private func setupHome() {
        let resourcePath = NSBundle.mainBundle().resourcePath!

        let pythonResources = "\(resourcePath)/Library/Python.framework/Resources"
        let wpython_home = _Py_char2wchar(pythonResources, nil)
        Py_SetPythonHome(wpython_home);
    }


    /// A private method used to setup the search path that CPython uses to find
    /// scripts
    private func setupPath() {
        let resourcePath = NSBundle.mainBundle().resourcePath!

        let wpath = Py_GetPath()
        let c = _Py_wchar2char(wpath, nil)
        let path = String(UTF8String: c)!

        let newPath = "\(path):\(resourcePath)"
        let wpythonPath = _Py_char2wchar(newPath, nil)
        PySys_SetPath(wpythonPath)
    }

    
    /// A private setup method used to lookup the __main__ module and store
    /// a reference to the mainModule property
    private func setupMain() {
        let module = PyImport_AddModule("__main__")
        mainModule = PythonObject(object: module)
        Py_DecRef(module)
    }
    
    /// A private method used to setup the Python function bridge.  This object
    /// is used to allow swift blocks to be callable by python.
    private func setupFunctionBridge() {
        callable = PythonFunctionBridge(engine: self)
    }
}



/// Extension used to provide description and debug strings for this class
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
