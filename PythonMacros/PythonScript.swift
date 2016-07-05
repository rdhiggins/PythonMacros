//
// PythonScript.swift
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


class PythonScript {

    var name: String?
    var location: PythonScriptLocation?
    var python: String?
    
    init(name: String, python: String?, location: PythonScriptLocation) {
        self.name = name
        self.python = python
        self.location = location
    }
    
    
    func run() -> Bool {
        return self.run(PythonMacroEngine.sharedInstance)
    }
    
    
    func run(engine: PythonMacroEngine) -> Bool {
        if let python = self.python {
            engine.run(python)
            
            return true
        }
        
        return false
    }
    
    
    class func createMemoryScript(name: String, python: String) -> PythonScript {
        let ps = PythonScript(name: name, python: python, location: .Memory)

        return ps
    }


    class func loadResourceScript(name: String) -> PythonScript? {
        return PythonScriptDirectory.sharedInstance.load(name, location: .Resource)
    }


    class func loadUserScript(name: String) -> PythonScript? {
        return PythonScriptDirectory.sharedInstance.load(name, location: .Document)
    }
}



func ==(lhs: PythonScript, rhs: PythonScript) -> Bool {
    if (lhs.name == rhs.name) && (lhs.location == rhs.location) {
        return true
    }
    
    return false
}