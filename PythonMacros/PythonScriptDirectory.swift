//
// PythonScriptDirectory.swift
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


/// A class used to manage stored scripts.
class PythonScriptDirectory {
    static let sharedInstance = PythonScriptDirectory()
    
    
    /// Property containing a list of Python scripts stored in the applications
    /// documents directory.
    var scripts: [PythonScript] = []
    
    /// Property containing a delegate object reference
    var delegate: PythonScriptDictionaryDelegate?
    
    fileprivate let fileManager = FileManager()
    fileprivate let docURL: URL =
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!

    
    init() {
        scan()
    }
    

    /// Method used to scan the application documents directory for any
    /// python scripts that are stored there.
    func scan() {
        var s: [PythonScript] = []
        
        let options = [
            URLResourceKey.nameKey,
            URLResourceKey.isDirectoryKey
        ]
        
        let files = try! fileManager.contentsOfDirectory(at: docURL, includingPropertiesForKeys: options, options: .skipsHiddenFiles)
        let scripts = files.filter() { ($0.lastPathComponent.hasSuffix(".py")) }
        
        for script in scripts {
            let url = script.deletingPathExtension()
            let name = url.lastPathComponent

            s.append(PythonScript(name: name, python: nil, location: .document))
        }
        
        self.scripts = s
        delegate?.scriptsUpdated()
    }
    
    
    /// Method used to load a script.
    ///
    /// - parameter name: A string specifying the filename (without extension)
    /// of the python script to load
    /// - parameter location: Where to load the script from
    func load(_ name: String, location: PythonScriptLocation) -> PythonScript? {
        var ret: PythonScript?
        
        switch location {
        case .memory:
            print("Can not load a memory script")
            
        case .resource:
            if let python = loadResourcePython(name) {
                ret  = PythonScript(name: name, python: python, location: .resource)
            }
            
        case .document:
            if let python = loadUserPython(name) {
                ret = PythonScript(name: name, python: python, location: .document)
            }
        }
        
        return ret
    }
    
    
    /// A method used to save a script to the applications documents directory.
    ///
    /// - parameter script: A PythonScript reference of the script to save.
    /// A script that is currently in memory will get stored to the application's
    /// documents directory
    /// - returns: A bool indicating success of failure of the save.
    func save(_ script: PythonScript) -> Bool {
        guard let location = script.location else { return false }
        var ret: Bool = false
        
        switch location {
        case .memory:
            ret = saveScript(script)
            script.location = .document
            
        case .document:
            ret = saveScript(script)
            
        case .resource:
            break
        }
        
        if ret { self.scan() }
        
        return ret
    }
    
    
    /// A method used to delete a script from the application's documents
    /// directory.
    ///
    /// - parameter script: A PythonScript reference of the script to delete.
    /// Only works for scripts that are stored in the application's
    /// documents directory.
    /// - returns: A bool indicating success of failure.  It will return false
    /// for scripts in memory or as part of the application's resource bundle
    func delete(_ script: PythonScript) -> Bool {
        guard let location = script.location,
                    let name = script.name else {
            return false
        }
        var ret: Bool = false
        
        switch location {
        case .memory:
            break
            
        case .resource:
            break
            
        case .document:
            let url = docURL.appendingPathComponent("\(name).py")
            
            do {
                try fileManager.removeItem(at: url)
                ret = true
            } catch {}
        }
        
        if ret {
            if let i = scripts.index(where: { $0 == script }) {
                scripts.remove(at: i)
                delegate?.scriptsUpdated()
            }
        }
        
        return ret
    }
    
    
    /// A method used to rename a script.  Only supports scripts that are
    /// located in the documents directory and have a name.
    ///
    /// - parameter oldName: The previous name of the PythonScript
    /// - parameter script: The PythonScript reference to rename.  The
    /// object must have the new name in its name property.
    /// - returns: A bool indicating success
    func rename(_ oldName: String, script: PythonScript) -> Bool {
        guard script.location == .document,
            let newName = script.name else { return false }
        
        var ret: Bool = false
        let oldUrl = docURL.appendingPathComponent("\(oldName).py")
        let newUrl = docURL.appendingPathComponent("\(newName).py")
        
        do {
            try fileManager.moveItem(at: oldUrl, to: newUrl)
            ret = true
        } catch {
            print("error in rename")
        }
        
        return ret
    }
    
    
    /// A method used to reload the script from storage.  Does nothing for
    /// memory scripts.
    ///
    /// - parameter script: The PythonScript reference to reload from storage.
    func refresh(_ script: PythonScript) {
        guard let location = script.location, let name = script.name else { return }
        
        switch location {
        case .memory:
            break
            
        case .resource:
            script.python = loadResourcePython(name)
            
        case .document:
            script.python = loadUserPython(name)
        }
    }
    
    
    /// A private method used to save a PythonScript object.
    ///
    /// - parameter script: A reference to a PythonScript object.
    /// - returns: A bool indicating success
    fileprivate func saveScript(_ script: PythonScript) -> Bool {
        var ret: Bool = false
        
        guard let name = script.name, let python = script.python else {
            return ret
        }
        
        let fileURL = docURL.appendingPathComponent("\(name).py")
        ret = savePython(python, url: fileURL)
        
        return ret
    }
    
    
    /// A private method used to store the python script string to the
    /// specified location as a NSUTF8StringEncoding
    ///
    /// - parameter python: A string containing the script to save
    /// - parameter url: A NSURL reference that specifies the location
    /// to write to.
    /// - returns: A bool indicating the success of the operation
    fileprivate func savePython(_ python: String, url: URL) -> Bool {
        do {
            try python.write(to: url, atomically: true, encoding: String.Encoding.utf8)
            return true
        } catch {}
        
        return false
    }
    
    
    /// A private method used to load the NSUTF8StringEncoding contents and
    /// returns it.
    ///
    /// - parameter url: A NSURL reference of the file to load the script from.
    /// - returns: A optional string containing the script if the operation
    /// was successful
    fileprivate func loadPython(_ url: URL) -> String? {
        var ret: String?
        
        do {
            ret = try String(contentsOf: url)
        } catch {}
        
        return ret
    }
    
    
    /// A method used to generate a unique name given a name inputted.  This
    /// method checks against the scripts property.  If the name is in the
    /// script property and is a different script, a new name is generated
    ///
    /// - parameter name: The proposed script name
    /// - returns: A unique string name
    func generateUniqueName(_ name: String) -> String {
        var uniqueName = name
        var index = 1
        
        while scripts.index(where: { $0.name == uniqueName }) != nil
        {
            uniqueName = "\(name) \(index)"
            index += 1
        }
        
        return uniqueName
    }


    /// A private method used to load a python string from the application
    /// resource bundle
    ///
    /// - parameter name: The filename (minus extension) to load
    /// - returns: A optional string containing the script if the operation
    /// was successful
    fileprivate func loadResourcePython(_ name: String) -> String? {
        guard let url = Bundle.main.url(forResource: name, withExtension: "py") else {
            print("Failed to find python script in mainBindle: \(name)")
            fatalError()
        }
        
        return loadPython(url)
    }
    
    
    /// A private method used to load a python string from the application
    /// document directory
    ///
    /// - parameter name: The filename (minus extension) to load
    /// - returns: A optional string containing the script if the operation
    /// was successful
    fileprivate func loadUserPython(_ name: String) -> String? {
        let url = docURL.appendingPathComponent("\(name).py")
        
        return loadPython(url)
    }
}



protocol PythonScriptDictionaryDelegate {
    /// Called when the list of scripts has changed
    func scriptsUpdated()
}
