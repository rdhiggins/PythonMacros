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


class PythonCaptureOutput {
    private let kValueKey = "value"
    private let kCaptureScriptName = "capture_output"
    private let kPythonStandardOutputName = "standardOutput"
    private let kPythonStandardErrorName = "standardError"
    
    private var module: PythonObject?
    private var standardOutput: PythonObject?
    private var standardError: PythonObject?
    private var engine: PythonMacroEngine!
    
    var stdOutput: String = String("")
    var stdError: String = String("")
    
    
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
    
    
    func refreshOutput() {
        refreshChannel(standardOutput!, channel: &stdOutput)
        refreshChannel(standardError!, channel: &stdError)
    }
    
    
    func clearBuffers() {
        stdOutput = ""
        stdError = ""
    }
    
    
    func dumpStandardOutput() {
        print(stdOutput, terminator: "")
    }
    
    
    func dumpStandardError() {
        print(stdError, terminator: "")
    }
    
    private func refreshChannel(object: PythonObject, inout channel: String) {
        guard let output = object.getAttrString(kValueKey) else {
            return
        }
        
        channel += output
        object.setAttrString(kValueKey, value: "")
    }
    
    
    private func loadCaptureScript() {
        guard let module = self.module,
            captureScript = PythonScriptDirectory.sharedInstance.load(kCaptureScriptName, location: .Resource) else {
                
            print("No module reference")
            fatalError()
        }
        
        if captureScript.run(engine) {
            // Get a reference to the python object
            standardOutput = module.getAttr(kPythonStandardOutputName)
            standardError = module.getAttr(kPythonStandardErrorName)
        }
    }
}



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
