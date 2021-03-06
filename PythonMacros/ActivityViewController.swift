//
// ActivityViewController.swift
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


/// View controller class that is used to demonstrate the calling
/// of macros in CPython
class ActivityViewController: UIViewController, DailyProgressDelegate {

    fileprivate let dailyProgress: DailyProgress = DailyProgress.sharedInstance
    
    fileprivate var macros: [PythonMacro] = []

    @IBOutlet weak var outerProgressView: CustomProgressView!
    @IBOutlet weak var middleProgressView: CustomProgressView!
    @IBOutlet weak var innerProgressView: CustomProgressView!
    @IBOutlet weak var messageLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        DailyProgress.sharedInstance.delegate = self
        
        setupMacros()
    }


    /// A private method used to setup the PythonMacros that will get called
    /// when the user selects one of four buttons displayed.
    fileprivate func setupMacros() {
        macros.append(PythonMacro(filename: "even_more", functionName: "evenMore"))
        macros.append(PythonMacro(filename: "more", functionName: "more"))
        macros.append(PythonMacro(filename: "less", functionName: "less"))
        macros.append(PythonMacro(filename: "even_less", functionName: "evenLess"))
    }


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditMacros" {
            if let emvc = segue.destination as? EditMacroViewController {
                emvc.macros = macros
            }
        }
    }


    @IBAction func callPythonMacro(_ sender: UIButton) {
        let r: String? = macros[sender.tag].call()
        messageLabel.text = r
    }



    func activeCalorieUpdate(_ newValue: Double) {
        outerProgressView.progress = CGFloat(newValue)
    }


    func activityUpdate(_ newValue: Double) {
        middleProgressView.progress = CGFloat(newValue)
    }


    func standupUpdate(_ newValue: Double) {
        innerProgressView.progress = CGFloat(newValue)
    }

    @IBAction func unwindFromEditMacro(_ segue: UIStoryboardSegue) {
        print("Unwound")
    }
}

