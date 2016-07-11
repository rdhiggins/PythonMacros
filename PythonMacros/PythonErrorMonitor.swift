//
// PythonErrorMonitor.swift
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


import UIKit

/// A class used by PythonMacroEngine to monitor the runtime for any errors.
/// A UIAlertController is displayed if any error are encounters.
class PythonErrorMonitor {

    private let engine: PythonMacroEngine

    init(engine: PythonMacroEngine) {
        self.engine = engine
    }


    /// The method used to check the runtime to any errors.  Currently it only
    /// looks at the captured standard error for error indications.
    ///
    /// TODO: Query the CPython runtime for any exceptions.
    func checkError() {

        // Only catching errors using stdError redirect
        if engine.output?.stdError.characters.count > 0 {
            let message = engine.output!.stdError
            engine.output!.stdError = ""

            let alert = UIAlertController(title: "Python Script Error", message: message, preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))

            alert.show(true)
        }
    }
}