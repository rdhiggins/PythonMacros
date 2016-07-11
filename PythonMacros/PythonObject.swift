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



/// A Class that holds a reference to a PyObject reference.  This reference
/// is a UnsafeMutablePointer<PyObject>.  This reference must be released when
/// the PythonObject is deleted.
///
/// This is used to manage PyObject references when interacting with the CPython
/// runtime.
class PythonObject {
    
    /// Property containing the reference to the PyObject
    let object: UnsafeMutablePointer<PyObject>
    
    
    /// Initialization method.  Passed the UnsafeMutablePointer<PyObject> to
    /// manage.
    ///
    /// - parameter object: UnsafeMutablePointer<PyObject> to manage
    init(object: UnsafeMutablePointer<PyObject>) {
        self.object = object
        Py_IncRef(self.object)
    }
    
    
    /// deinit needs to decrement the CPython reference count for the
    /// object.
    deinit {
        Py_DecRef(object)
    }
    
    
    /// Method used to lookup a attribute of the managed PyObject.
    ///
    /// - parameter attribute: A string containing the name of the
    /// attribute to lookup.
    /// - returns: A string of the attribute contents requested on
    /// success.
    func getAttrString(attribute: String) -> String? {
        let pyOutput = PyObject_GetAttrString(object, attribute)
        let output = String(UTF8String: PyUnicode_AsUTF8(pyOutput))
        Py_DecRef(pyOutput)
        
        return output
    }
    
    
    /// Method used to set a attribute on the manager PyObject.
    ///
    /// - parameter attribute: A string containing the name of the attribute.
    /// - parameter value: A string containing the new value to set the
    /// attribute to.
    func setAttrString(attribute: String, value: String) {
        PyObject_SetAttrString(object,
                        attribute,
                        PyUnicode_DecodeUTF8(value, value.utf8.count, nil))
    }
    
    
    /// A method used to get a PythonObject reference of a PyObject
    /// attribute.
    ///
    /// - parameter attribute:  A string containing the attribute name to
    /// get the value of.
    /// - returns: A PythonObject reference
    func getAttr(attribute: String) -> PythonObject {
        let ref = PyObject_GetAttr(object,
                                   PyUnicode_DecodeUTF8(attribute,
                                                        attribute.utf8.count,
                                                        nil))

        let newObject = PythonObject(object: ref)
        Py_DecRef(ref)

        return newObject
    }
    

    
    /// A method used to convert the PyObject to a string.
    ///
    /// returns: Optional string contents to the managed PyObject
    func toString() -> String? {
        let ref = PyObject_Str(object)
        let output = String(UTF8String: PyUnicode_AsUTF8(ref))
        Py_DecRef(ref)
        
        return output
    }


    /// A method used to return the Float value of the managed PyObject.
    ///
    /// returns: Float value of the PyObject
    func toFloat() -> Float {
        return Float(PyFloat_AsDouble(object))
    }
    
    
    /// A method used to return the Double value of the managed PyObject.
    ///
    /// returns: Double value of the PyObject
    func toDouble() -> Double {
        return PyFloat_AsDouble(object)
    }
 
    
    /// A method used to return the Int value of the managed PyObject.
    ///
    /// returns: Int value of the PyObject
    func toInt() -> Int {
        return Int(PyLong_AsLong(object))
    }

    
    /// A method used to return the Int64 value of the managed PyObject.
    ///
    /// returns: Int64 value of the PyObject
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