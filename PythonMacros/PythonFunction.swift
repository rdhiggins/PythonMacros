//
// PythonFunction.swift
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


typealias PythonFunctionBlock = ([AnyObject]?) -> AnyObject?


/// Class used to represent a python callable swift block.
class PythonFunction {
    
    /// Enum defining the supported python types
    enum PythonTypes: String {
        case Double = "d"
        case Float = "f"
        case Int = "i"
        case Long = "l"
        case String = "s"
        case Void = "v"
    }
    
    
    /// Property containing the function name for the swift block
    var name: String
    
    
    /// Property containing the array of types for the arguments to the 
    /// swift blocks
    var callArgs: [PythonTypes]
    
    
    /// Property that specifies the python return type of the swift block
    var returnType: PythonTypes
    
    
    /// Property containing the actual swift block that will be called
    /// from CPython
    var block: PythonFunctionBlock
    

    /// Initialization method.
    ///
    /// - parameter name: The name of the function in Python
    /// - parameter callArgs:  Array of PythonTypes that specify the number and
    /// type of the functions arguments
    /// - parameter returnType: The PythonType of the return value
    /// - parameter block: The swift block to call from python
    init(name: String, callArgs: [PythonTypes], returnType: PythonTypes, block: @escaping PythonFunctionBlock) {
        self.name = name
        self.callArgs = callArgs
        self.returnType = returnType
        self.block = block
    }
    

    /// Public method used by the PythonFunctionBridge to call the swift block.
    ///
    /// - parameter args: An array of the arguments that should be passed
    /// to the swift block
    /// - returns: The object (if any) to be passwed back to the python
    /// runtime.
    func call(_ args: [AnyObject]?) -> AnyObject? {
        return block(args)
    }


    /// Public method used by the PythonFunctionBridge to parse the PyObject
    /// tuple that contains the blocks argument values.  This method then
    /// returns the array of values that are passed to the swift block.
    ///
    /// - parameter tuple: The UnsafeMutablePointer<PyObject> of the argument
    /// tuple in python.
    /// - returns: Array of swift values that will be passed to the swift block
    func parseArgs(_ tuple: UnsafeMutablePointer<PyObject>) -> [AnyObject] {
        var ret: [AnyObject] = []
        var index: Int = 0

        for arg in callArgs {
            let obj: UnsafeMutablePointer<PyObject>? = PyTuple_GetItem(tuple, index)

            if obj != nil {
                switch arg {
                case .Double:
                    if PyNumber_Check(obj) != 0 {
                        ret.append(PyFloat_AsDouble(obj) as AnyObject)
                    } else {
                        PyErr_SetString(PyExc_TypeError, "Expected float as param \(index+1)")
                    }
                case .Float:
                    if PyNumber_Check(obj) != 0 {
                        ret.append(Float(PyFloat_AsDouble(obj)) as AnyObject)
                    } else {
                        PyErr_SetString(PyExc_TypeError, "Expected float as param \(index+1)")
                    }
                case .String:
                    let flags = obj?.pointee.ob_type.pointee.tp_flags
                    if  flags! & Py_TPFLAGS_UNICODE_SUBCLASS != 0 {
                        ret.append(String(validatingUTF8: PyUnicode_AsUTF8AndSize(obj, nil))! as AnyObject)
                    } else {
                        PyErr_SetString(PyExc_TypeError, "Expected string as param \(index+1)")
                    }
                case .Int:
                    if PyNumber_Check(obj) != 0 {
                        ret.append(PyLong_AsLong(obj) as AnyObject)
                    } else {
                        PyErr_SetString(PyExc_TypeError, "Expected int as param \(index+1)")
                    }
                case .Long:
                    if PyNumber_Check(obj) != 0 {
                        ret.append(PyLong_AsLong(obj) as AnyObject)
                    } else {
                        PyErr_SetString(PyExc_TypeError, "Expected long as param \(index+1)")
                    }
                default:
                    print("Void parameters are not allowed")
                    fatalError()
                }
            }

            index += 1
        }

        return ret
    }


    /// A public method used by the PythonFunctionBridge object to encode the
    /// return type from the swift block into a proper python PyObject.
    ///
    /// - parameter returnValue: The return value to encode
    /// - returns: A UnsafeMutablePointer<PyObject> that is the value encoded
    /// into the proper python object
    func encodeReturn(_ returnValue: AnyObject?) -> UnsafeMutablePointer<PyObject>? {
        switch returnType {
        case .Double:
            guard let d = returnValue as? Double else {
                PyErr_SetString(PyExc_ValueError, "Expected Double from block")
                return nil
            }
            return createPythonReturnObject(d)
        case .Float:
            guard let f = returnValue as? Float else {
                PyErr_SetString(PyExc_ValueError, "Expected Float from block")
                return nil
            }
            return createPythonReturnObject(f)
        case .Int:
            guard let i = returnValue as? Int else {
                PyErr_SetString(PyExc_ValueError, "Expected Int from block")
                return nil
            }
            return createPythonReturnObject(i)
        case .Long:
            guard let l = returnValue as? Int64 else {
                PyErr_SetString(PyExc_ValueError, "Expected Int64 from block")
                return nil
            }
            return createPythonReturnObject(l)
        case .String:
            guard let s = returnValue as? String else {
                PyErr_SetString(PyExc_ValueError, "Expected String from block")
                return nil
            }
            return s.withCString() { str in
                return createPythonReturnObject(str)
            }
        case .Void:
            return PyNone_Ref()
        }
    }


    /// A private method used to create the return value in the CPython runtime.
    ///
    /// - parameter value: The swift value to encode into the python runtime
    /// - returns: A UnsafeMutablePointer<PyObject> of the encoded
    /// PyObject.
    fileprivate func createPythonReturnObject<ValueType: CVarArg>(_ value: ValueType) -> UnsafeMutablePointer<PyObject> {
        let args: [CVarArg] = [value]
        
        return withVaList(args) { va_list in
            return Py_VaBuildValue(returnType.rawValue, va_list)
        }
    }
}
