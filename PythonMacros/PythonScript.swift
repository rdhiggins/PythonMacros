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



/// Class that represents a Python script.  This class is used to load scripts
/// for the application and execute them in the CPython runtime.
class PythonScript {

    /// Property containing the filename (minus the extension) of the python
    /// script.
    var name: String?
    
    
    /// Property specifies where the script was loaded from.
    var location: PythonScriptLocation?
    
    /// Property containing the actual python script.
    var python: String?
    
    
    init(name: String, python: String?, location: PythonScriptLocation) {
        self.name = name
        self.python = python
        self.location = location
    }
    
    
    /// Method used to execute the python script in the CPython runtime.
    ///
    /// returns: A bool indicating the success or failure of running
    /// the script in CPython runtime.  Only returns false if there is nothing
    /// in the python property
    func run() -> Bool {
        return self.run(PythonMacroEngine.sharedInstance)
    }
    
    
    /// Method used to execute the python script in the specified CPython
    /// runtime.
    ///
    /// - parameter engine: PythonMacroEngine reference to execute the script in
    /// returns: A bool indicating the success or failure of running
    /// the script in CPython runtime.  Only returns false if there is nothing
    /// in the python property
    func run(_ engine: PythonMacroEngine) -> Bool {
        if let python = self.python {
            engine.run(python)
            
            return true
        }
        
        return false
    }
    
    
    /// A class method used to create a PythonScript object with a python script
    /// already loaded in memory.
    ///
    /// - paramter name: A string containing the name of the python script.
    class func createMemoryScript(_ name: String, python: String) -> PythonScript {
        let ps = PythonScript(name: name, python: python, location: .memory)

        return ps
    }


    /// A class method used to load a script from the application resource bundle.
    ///
    /// - parameter name:  A filename (minus extension) of the script to load
    /// the resource bundle.
    /// - returns: A PythonScript on successfully loading the specified script.
    class func loadResourceScript(_ name: String) -> PythonScript? {
        return PythonScriptDirectory.sharedInstance.load(name, location: .resource)
    }


    /// A class method used to load a script from the applications document
    /// directory.
    ///
    /// - parameter name:  A filename (minus extension) of the script to load
    /// the resource bundle.
    /// - returns: A PythonScript on successfully loading the specified script.
    class func loadUserScript(_ name: String) -> PythonScript? {
        return PythonScriptDirectory.sharedInstance.load(name, location: .document)
    }
}


/// Function used to test if two PythonScript objects are equivalent.
///
/// - returns:  True if the two objects are equal
func ==(lhs: PythonScript, rhs: PythonScript) -> Bool {
    if (lhs.name == rhs.name) && (lhs.location == rhs.location) {
        return true
    }
    
    return false
}
