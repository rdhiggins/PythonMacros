//
// PythonCaptureOutput.swift
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



/// A class that is used to capture the output streams from CPython.  It loads
/// the capture_output.py script and executes it.  This script creates two
/// python objects that capture standard out and standard error.
///
/// The refreshOutput is called after CPython executes something.  The Python
/// objects a queryied for any text, which is then appended to the stdOutput or
/// stdError buffers.
class PythonCaptureOutput {
    private let kValueKey = "value"
    private let kCaptureScriptName = "capture_output"
    private let kPythonStandardOutputName = "standardOutput"
    private let kPythonStandardErrorName = "standardError"
    
    private var module: PythonObject?
    private var standardOutput: PythonObject?
    private var standardError: PythonObject?
    private var engine: PythonMacroEngine!
    
    
    /// Property that contains the standard output from CPython
    var stdOutput: String = String("")
    
    
    /// Property that contains the standard error output from CPython
    var stdError: String = String("")
    
    
    /// Initialization method that is called by PythonMacroEngine during
    /// it's initialization process.
    ///
    /// - parameter module: A PythonObject reference to the __main__ module.
    /// - parameter engine: A PythonMacroEngine reference used by the new object
    /// to monitor.
    init(module: PythonObject, engine: PythonMacroEngine) {
        self.engine = engine
        
        self.module = module
        
        loadCaptureScript()
    }
    
    
    deinit {
        module = nil
        standardOutput = nil
        standardError = nil
    }
    
    
    /// Method used to query the Python objects used to capture the streams.
    func refreshOutput() {
        refreshChannel(standardOutput!, channel: &stdOutput)
        refreshChannel(standardError!, channel: &stdError)
    }
    
    
    /// Method used to clear the stdOutput and stdError buffers
    func clearBuffers() {
        stdOutput = ""
        stdError = ""
    }
    
    
    /// A private method used to query a Python object for the captured output.
    /// The PythonObject reference to the particular python channel.  The Python
    /// object's captured output is then cleared.
    ///
    /// - parameter object: A PythonObject reference to the python object used
    /// to capture the stream output.
    /// - parameter channel: The String buffer to append any new output to.
    private func refreshChannel(object: PythonObject, inout channel: String) {
        // This queries the python object for its new content
        guard let output = object.getAttrString(kValueKey) else {
            return
        }
        
        // content is appended to the buffer
        channel += output
        
        // This clears the python objects content
        object.setAttrString(kValueKey, value: "")
    }
    
    
    /// A private method that performs the setup for capturing the streams
    /// from CPython.  It first loads the capture_python.py script from the
    /// applications resource bundle and then executes it in the CPython
    /// runtime.
    ///
    /// The two python objects are then looked up and references
    /// are stored so the the stream output can be queried.
    private func loadCaptureScript() {
        guard let module = self.module,
            captureScript = PythonScriptDirectory.sharedInstance.load(kCaptureScriptName, location: .Resource) else {
                
            print("No module reference")
            fatalError()
        }
        
        if captureScript.run(engine) {
            // Get a reference to the python objects used to capture the
            // output streams.
            standardOutput = module.getAttr(kPythonStandardOutputName)
            standardError = module.getAttr(kPythonStandardErrorName)
        }
    }
}


/// Extension used to provide description and debug description string
extension PythonCaptureOutput: CustomStringConvertible, CustomDebugStringConvertible {
    var description: String {
        return customDescription()
    }

    
    var debugDescription: String {
        return
            "PythonCaptureOutput {\n" +
                " module: \(module.debugDescription)\n" +
                " std_out: \(standardOutput.debugDescription)\n" +
                " std_err: \(standardError.debugDescription)\n" +
        "}"
    }

    
    private func customDescription() -> String {
        return "Python StandardOutput: \(stdOutput)\nPython StandardError: \(stdError)\n"
    }
}
