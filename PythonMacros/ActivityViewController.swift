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

class ActivityViewController: UIViewController, DailyProgressDelegate {

    private let dailyProgress: DailyProgress = DailyProgress.sharedInstance
    
    private var macros: [PythonMacro] = []

    @IBOutlet weak var outerProgressView: CustomProgressView!
    @IBOutlet weak var middleProgressView: CustomProgressView!
    @IBOutlet weak var innerProgressView: CustomProgressView!
    @IBOutlet weak var messageLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        DailyProgress.sharedInstance.delegate = self
        
        setupMacros()
    }

    
    private func setupMacros() {
        macros.append(PythonMacro(filename: "even_more", functionName: "evenMore"))
        macros.append(PythonMacro(filename: "more", functionName: "more"))
        macros.append(PythonMacro(filename: "less", functionName: "less"))
        macros.append(PythonMacro(filename: "even_less", functionName: "evenLess"))
    }


    @IBAction func evenMoreProgress(sender: UIButton) {
        dailyProgress.activeCalories += 10 * drand48()
        dailyProgress.activity += 10 * drand48()
        dailyProgress.standup += 10 * drand48()
        
        let r: String? = macros[0].call()
        messageLabel.text = r
    }
    
    
    @IBAction func moreProgress(sender: UIButton) {
        dailyProgress.activeCalories += drand48()
        dailyProgress.activity += drand48()
        dailyProgress.standup += drand48()

        let r: String? = macros[1].call()
        messageLabel.text = r
    }
    
    
    @IBAction func lessProgress(sender: UIButton) {
        dailyProgress.activeCalories -= drand48()
        dailyProgress.activity -= drand48()
        dailyProgress.standup -= drand48()

        let r: String? = macros[2].call()
        messageLabel.text = r
    }

    
    @IBAction func evenLessProgress(sender: UIButton) {
        dailyProgress.activeCalories -= 10 * drand48()
        dailyProgress.activity -= 10 * drand48()
        dailyProgress.standup -= 10 * drand48()
        
        let r: String? = macros[3].call()
        messageLabel.text = r
    }


    func activeCalorieUpdate(newValue: Double) {
        outerProgressView.progress = CGFloat(newValue)
    }


    func activityUpdate(newValue: Double) {
        middleProgressView.progress = CGFloat(newValue)
    }


    func standupUpdate(newValue: Double) {
        innerProgressView.progress = CGFloat(newValue)
    }
}

