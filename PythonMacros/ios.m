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

static int blocks = 0;

process_block ios_process_block;

static PyObject *iOS_numBlocks(PyObject *self, PyObject *args)
{
    if (!PyArg_ParseTuple(args, ":blocks"))
        return NULL;

    return PyLong_FromLong(blocks);
}


static PyObject *iOS_callBlock(PyObject *self, PyObject *args)
{
    return ios_process_block(args);
}

static PyMethodDef iOS_Methods[] = {
    { "blocks", iOS_numBlocks, METH_VARARGS, "Returns the number of blocks installed"},
    { "call", iOS_callBlock, METH_VARARGS, "Call Objective-C block"},
    { NULL, NULL, 0, NULL }
};


static PyModuleDef iOS_Module = {
    PyModuleDef_HEAD_INIT, "ios", NULL, -1, iOS_Methods, NULL, NULL, NULL, NULL
};


static PyObject *PyInit_iOS(void)
{
    return PyModule_Create(&iOS_Module);
}


void init_ios_module() {
    PyImport_AppendInittab("ios", &PyInit_iOS);
}



PyObject *PyNone_Ref() {
    Py_IncRef(Py_None);
    
    return Py_None;
}