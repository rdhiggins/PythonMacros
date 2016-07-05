//
//  DailyProgress.swift
//  PythonMacros
//
//  Created by Rodger Higgins on 7/5/16.
//  Copyright © 2016 Rodger Higgins. All rights reserved.
//

import Foundation


class DailyProgress {
    static var sharedInstance: DailyProgress = DailyProgress()


    var activeCalories: Double = 0.0 {
        didSet {
            delegate?.activeCalorieUpdate(activeCalories)
        }
    }


    var activity: Double = 0.0 {
        didSet {
            delegate?.activityUpdate(activity)
        }
    }


    var standup: Double = 0.0 {
        didSet {
            delegate?.standupUpdate(standup)
        }
    }


    var delegate: DailyProgressDelegate?


    init() {
        setupPythonCallbacks()
    }


    private func setupPythonCallbacks() {

    }
}


protocol DailyProgressDelegate {
    func activeCalorieUpdate(newValue: Double)
    func activityUpdate(newValue: Double)
    func standupUpdate(newValue: Double)
}