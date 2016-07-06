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
    
    private var engine: PythonMacroEngine = PythonMacroEngine.sharedInstance
    private var functions: [PythonFunction] = []

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
        functions.append(PythonFunction(name: "getActiveCalories", callArgs: [], returnType: .Double, block: { Void -> AnyObject? in
            return self.activeCalories
        }))
        engine.callable?.registerFunction(functions.last!)
        
        functions.append(PythonFunction(name: "setActiveCalories", callArgs: [.Double], returnType: .Void, block: { (args) -> AnyObject? in
            guard let newValue = args?[0] as? Double else { return nil }
            
            self.activeCalories = newValue
            
            return nil
        }))
        engine.callable?.registerFunction(functions.last!)
        
        
        functions.append(PythonFunction(name: "getActivity", callArgs: [], returnType: .Double, block: { Void -> AnyObject? in
            return self.activity
        }))
        engine.callable?.registerFunction(functions.last!)
        
        functions.append(PythonFunction(name: "setActivity", callArgs: [.Double], returnType: .Void, block: { (args) -> AnyObject? in
            guard let newValue = args?[0] as? Double else { return nil }
            
            self.activity = newValue
            
            return nil
        }))
        engine.callable?.registerFunction(functions.last!)
        
        
        functions.append(PythonFunction(name: "getStandup", callArgs: [], returnType: .Double, block: { Void -> AnyObject? in
            return self.standup
        }))
        engine.callable?.registerFunction(functions.last!)
        
        functions.append(PythonFunction(name: "setStandup", callArgs: [.Double], returnType: .Void, block: { (args) -> AnyObject? in
            guard let newValue = args?[0] as? Double else { return nil }
            
            self.standup = newValue
            
            return nil
        }))
        engine.callable?.registerFunction(functions.last!)
    }
}


protocol DailyProgressDelegate {
    func activeCalorieUpdate(newValue: Double)
    func activityUpdate(newValue: Double)
    func standupUpdate(newValue: Double)
}