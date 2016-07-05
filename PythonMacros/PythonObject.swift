//
// PythonObject.swift
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


class PythonObject {
    
    let object: UnsafeMutablePointer<PyObject>
    
    
    
    
    init(object: UnsafeMutablePointer<PyObject>) {
        self.object = object
        Py_IncRef(self.object)
    }
    
    
    deinit {
        Py_DecRef(object)
    }
    
    
    func getAttrString(attribute: String) -> String? {
        let pyOutput = PyObject_GetAttrString(object, attribute)
        let output = String(UTF8String: PyUnicode_AsUTF8(pyOutput))
        Py_DecRef(pyOutput)
        
        return output
    }
    
    
    func setAttrString(attribute: String, value: String) {
        PyObject_SetAttrString(object,
                        attribute,
                        PyUnicode_DecodeUTF8(value, value.utf8.count, nil))
    }
    
    
    func getAttr(attribute: String) -> PythonObject {
        let ref = PyObject_GetAttr(object,
                                   PyUnicode_DecodeUTF8(attribute,
                                                        attribute.utf8.count,
                                                        nil))

        let newObject = PythonObject(object: ref)
        Py_DecRef(ref)

        PyErr_Print()
        PyErr_Clear()
        
        return newObject
    }
    

    func toString() -> String? {
        let ref = PyObject_Str(object)
        let output = String(UTF8String: PyUnicode_AsUTF8(ref))
        Py_DecRef(ref)
        
        return output
    }

    func toBool() -> Bool {
        return false
    }
    
    func toFloat() -> Float {
        return Float(PyFloat_AsDouble(object))
    }
    
    func toDouble() -> Double {
        return PyFloat_AsDouble(object)
    }
 
    func toInt() -> Int {
        return Int(PyLong_AsLong(object))
    }
    
    func toInt64() -> Int64 {
        return Int64(PyLong_AsLong(object))
    }
}




extension PythonObject: CustomDebugStringConvertible, CustomStringConvertible {
    var debugDescription: String {
        return self.customDescription()
    }
    
    var description: String {
        return self.customDescription()
    }
    
    
    private func customDescription() -> String {
        if let s = self.toString() {
            return "python object: \(s)"
        }
        
        return "pythong object: unknown"
    }    
}