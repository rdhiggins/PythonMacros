//
//  DailyProgress.swift
//  PythonMacros
//
//  Created by Rodger Higgins on 7/5/16.
//  Copyright © 2016 Rodger Higgins. All rights reserved.
//

import Foundation


/// Class used to store the global progress model used for this tutorial.  The
/// daily progress is represented as three properties off of the singleton.
///
/// This class also register 6 swift blocks into the CPython runtime.  These
/// python functions are used by python scripts to retrieve/set each of the
/// three progress values.
///
/// This class also supports a delegate for getting notification of
/// any progress changes.
class DailyProgress {

    /// Class property used to retrieve the singleton object
    static var sharedInstance: DailyProgress = DailyProgress()
    
    fileprivate var engine: PythonMacroEngine = PythonMacroEngine.sharedInstance
    fileprivate var functions: [PythonFunction] = []


    /// Property containing the current value for the daily active calories
    var activeCalories: Double = 0.0 {
        didSet {
            delegate?.activeCalorieUpdate(activeCalories)
        }
    }


    /// Property containing the current value for the daily active minutes
    var activity: Double = 0.0 {
        didSet {
            delegate?.activityUpdate(activity)
        }
    }


    /// Property containing the current number of standup hours
    var standup: Double = 0.0 {
        didSet {
            delegate?.standupUpdate(standup)
        }
    }


    /// Property used to register delegate
    var delegate: DailyProgressDelegate?


    init() {
        setupPythonCallbacks()
    }


    /// A private method used to register the swift blocks with the
    /// PythonMacroEngine.
    fileprivate func setupPythonCallbacks() {
        functions.append(
            PythonFunction(name: "getActiveCalories",
                       callArgs: [],
                     returnType: .Double,
                          block:
        {
            Void -> AnyObject? in

            return self.activeCalories as AnyObject!
        }))
        _ = engine.callable?.registerFunction(functions.last!)


        functions.append(
            PythonFunction(name: "setActiveCalories",
                       callArgs: [.Double],
                     returnType: .Void,
                          block:
        {
            (args) -> AnyObject? in

            guard let newValue = args?[0] as? Double else { return nil }
            
            self.activeCalories = newValue
            
            return nil
        }))
        _ = engine.callable?.registerFunction(functions.last!)
        
        
        functions.append(
            PythonFunction(name: "getActivity",
                       callArgs: [],
                     returnType: .Double,
                          block:
        {
            Void -> AnyObject? in

            return self.activity as AnyObject!
        }))
        _ = engine.callable?.registerFunction(functions.last!)


        functions.append(
            PythonFunction(name: "setActivity",
                       callArgs: [.Double],
                     returnType: .Void,
                          block:
        {
            (args) -> AnyObject? in

            guard let newValue = args?[0] as? Double else { return nil }

            self.activity = newValue
            
            return nil
        }))
        _ = engine.callable?.registerFunction(functions.last!)
        
        
        functions.append(
            PythonFunction(name: "getStandup",
                       callArgs: [],
                     returnType: .Double,
                          block:
        {
            Void -> AnyObject? in

            return self.standup as AnyObject!
        }))
        _ = engine.callable?.registerFunction(functions.last!)


        functions.append(
            PythonFunction(name: "setStandup",
                       callArgs: [.Double],
                     returnType: .Void,
                          block:
        {
            (args) -> AnyObject? in

            guard let newValue = args?[0] as? Double else { return nil }
            
            self.standup = newValue
            
            return nil
        }))
        _ = engine.callable?.registerFunction(functions.last!)
    }
}


protocol DailyProgressDelegate {
    func activeCalorieUpdate(_ newValue: Double)
    func activityUpdate(_ newValue: Double)
    func standupUpdate(_ newValue: Double)
}
