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


class PythonScriptDirectory {
    static let sharedInstance = PythonScriptDirectory()
    
    var scripts: [PythonScript] = []
    var delegate: PythonScriptDictionaryDelegate?
    
    private let fileManager = NSFileManager()
    private let docURL: NSURL =
        NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).last!

    
    init() {
        scan()
    }
    

    func scan() {
        var s: [PythonScript] = []
        
        let options = [
            NSURLNameKey,
            NSURLIsDirectoryKey
        ]
        
        let files = try! fileManager.contentsOfDirectoryAtURL(docURL, includingPropertiesForKeys: options, options: .SkipsHiddenFiles)
        let scripts = files.filter() { ($0.lastPathComponent?.hasSuffix(".py"))! }
        
        for script in scripts {
            guard let url = script.URLByDeletingPathExtension,
                name = url.lastPathComponent else { continue }

            s.append(PythonScript(name: name, python: nil, location: .Document))
        }
        
        self.scripts = s
        delegate?.scriptsUpdated()
    }
    
    func update() {
        delegate?.scriptsUpdated()
    }


    func load(name: String, location: PythonScriptLocation) -> PythonScript? {
        var ret: PythonScript?
        
        switch location {
        case .Memory:
            print("Can not load a memory script")
            
        case .Resource:
            if let python = loadResourcePython(name) {
                ret  = PythonScript(name: name, python: python, location: .Resource)
            }
            
        case .Document:
            if let python = loadUserPython(name) {
                ret = PythonScript(name: name, python: python, location: .Document)
            }
        }
        
        return ret
    }
    
    
    func save(script: PythonScript) -> Bool {
        guard let location = script.location else { return false }
        var ret: Bool = false
        
        switch location {
        case .Memory:
            ret = saveScript(script)
            script.location = .Document
            
        case .Document:
            ret = saveScript(script)
            
        case .Resource:
            break
        }
        
        if ret { self.scan() }
        
        return ret
    }
    
    
    func delete(script: PythonScript) -> Bool {
        guard let location = script.location,
                    name = script.name else {
            return false
        }
        var ret: Bool = false
        
        switch location {
        case .Memory:
            break
            
        case .Resource:
            break
            
        case .Document:
            let url = docURL.URLByAppendingPathComponent("\(name).py")
            
            do {
                try fileManager.removeItemAtURL(url)
                ret = true
            } catch {}
        }
        
        if ret {
            if let i = scripts.indexOf({ $0 == script }) {
                scripts.removeAtIndex(i)
                delegate?.scriptsUpdated()
            }
        }
        
        return ret
    }
    
    
    func rename(oldName: String, script: PythonScript) {
        guard let newName = script.name else { return }
        
        let oldUrl = docURL.URLByAppendingPathComponent("\(oldName).py")
        let newUrl = docURL.URLByAppendingPathComponent("\(newName).py")
        
        do {
            try fileManager.moveItemAtURL(oldUrl, toURL: newUrl)
        } catch {
            print("error in rename")
        }
    }
    
    
    func refresh(script: PythonScript) {
        guard let location = script.location, name = script.name else { return }
        
        switch location {
        case .Memory:
            break
            
        case .Resource:
            script.python = loadResourcePython(name)
            
        case .Document:
            script.python = loadUserPython(name)
        }
    }
    
    private func saveScript(script: PythonScript) -> Bool {
        var ret: Bool = false
        
        guard let name = script.name, python = script.python else {
            return ret
        }
        
        let fileURL = docURL.URLByAppendingPathComponent("\(name).py")
        ret = savePython(python, url: fileURL)
        
        print("done")
        
        return ret
    }
    
    
    private func savePython(python: String, url: NSURL) -> Bool {
        do {
            try python.writeToURL(url, atomically: true, encoding: NSUTF8StringEncoding)
            return true
        } catch {}
        
        return false
    }
    
    
    private func loadPython(url: NSURL) -> String? {
        var ret: String?
        
        do {
            ret = try String(contentsOfURL: url)
        } catch {}
        
        return ret
    }
    
    
    func generateUniqueName(name: String) -> String {
        var uniqueName = name
        var index = 1
        
        while scripts.indexOf({ $0.name == uniqueName }) != nil
        {
            uniqueName = "\(name) \(index)"
            index += 1
        }
        
        return uniqueName
    }

    
    private func loadResourcePython(name: String) -> String? {
        guard let url = NSBundle.mainBundle().URLForResource(name, withExtension: "py") else {
            print("Failed to find python script in mainBindle: \(name)")
            fatalError()
        }
        
        return loadPython(url)
    }
    
    
    private func loadUserPython(name: String) -> String? {
        let url = docURL.URLByAppendingPathComponent("\(name).py")
        
        return loadPython(url)
    }
}



protocol PythonScriptDictionaryDelegate {
    func scriptsUpdated()
}