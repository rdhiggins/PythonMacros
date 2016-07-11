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


typealias PythonFunctionBlock = [AnyObject]? -> AnyObject?


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
    
    
    init(name: String, callArgs: [PythonTypes], returnType: PythonTypes, block: PythonFunctionBlock) {
        self.name = name
        self.callArgs = callArgs
        self.returnType = returnType
        self.block = block
    }
    
    
    func call(args: [AnyObject]?) -> AnyObject? {
        return block(args)
    }
    
    
    private func argsFormatString() -> String {
        var ret = ""
        
        for arg in callArgs {
            ret += arg.rawValue
        }
        
        return ret
    }
    
    
    private func returnTypeFormat() -> String {
        return returnType.rawValue
    }


    func parseArgs(tuple: UnsafeMutablePointer<PyObject>) -> [AnyObject] {
        var ret: [AnyObject] = []
        var index: Int = 0

        for arg in callArgs {
            let obj: UnsafeMutablePointer<PyObject> = PyTuple_GetItem(tuple, index)

            if obj != nil {
                switch arg {
                case .Double:
                    if PyNumber_Check(obj) != 0 {
                        ret.append(PyFloat_AsDouble(obj))
                    } else {
                        PyErr_SetString(PyExc_TypeError, "Expected float as param \(index+1)")
                    }
                case .Float:
                    if PyNumber_Check(obj) != 0 {
                        ret.append(Float(PyFloat_AsDouble(obj)))
                    } else {
                        PyErr_SetString(PyExc_TypeError, "Expected float as param \(index+1)")
                    }
                case .String:
                    let flags = obj.memory.ob_type.memory.tp_flags
                    if  flags & Py_TPFLAGS_UNICODE_SUBCLASS != 0 {
                        ret.append(String(UTF8String: PyUnicode_AsUTF8AndSize(obj, nil))!)
                    } else {
                        PyErr_SetString(PyExc_TypeError, "Expected string as param \(index+1)")
                    }
                case .Int:
                    if PyNumber_Check(obj) != 0 {
                        ret.append(PyLong_AsLong(obj))
                    } else {
                        PyErr_SetString(PyExc_TypeError, "Expected int as param \(index+1)")
                    }
                case .Long:
                    if PyNumber_Check(obj) != 0 {
                        ret.append(PyLong_AsLong(obj))
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


    func encodeReturn(returnValue: AnyObject?) -> UnsafeMutablePointer<PyObject> {
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
    
    
    private func createPythonReturnObject<ValueType: CVarArgType>(value: ValueType) -> UnsafeMutablePointer<PyObject> {
        let args: [CVarArgType] = [value]
        
        return withVaList(args) { va_list in
            return Py_VaBuildValue(returnType.rawValue, va_list)
        }
    }
}