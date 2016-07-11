//
// ios.m
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

#import <Foundation/Foundation.h>
#import "Python/Python.h"
#import "ios.h"


// Python method used to call registered blocks.  It calls back to swift to
// actually progress the call.  The Python parameters are:
//  1. block name as a string
//  2. tup-le of paramters to pass to the swift block.
//
//  returns:
//  1. Python return type
static PyObject *iOS_callBlock(PyObject *self, PyObject *args)
{
    return ios_process_block(args);
}


// Table that lists the valid Python methods in this module
static PyMethodDef iOS_Methods[] = {
    { "call", iOS_callBlock, METH_VARARGS, "Call Objective-C block"},
    { NULL, NULL, 0, NULL }
};


// Table that contains the definition for this module
static PyModuleDef iOS_Module = {
    PyModuleDef_HEAD_INIT, "ios", NULL, -1, iOS_Methods, NULL, NULL, NULL, NULL
};


// Routine used by CPython to initialize this module
static PyObject *PyInit_iOS(void)
{
    return PyModule_Create(&iOS_Module);
}


// Method used by swift to register this module with CPython.  It appends
// the module definition table to the list of modules that CPython know about.
void init_ios_module() {
    PyImport_AppendInittab("ios", &PyInit_iOS);
}



// Utility function used to return the Py_None object to swift.  Used to return
// null from Python methods implemented as swift blocks.
PyObject *PyNone_Ref() {
    Py_IncRef(Py_None);
    
    return Py_None;
}