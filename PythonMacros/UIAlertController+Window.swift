//
//  UIAlertController+Window.swift
//  PythonTest.Swift
//
//  Created by Rodger Higgins on 6/16/16.
//  Copyright © 2016 Rodger Higgins. All rights reserved.
//

import UIKit

// Need this
private var alertWindowKey: UInt8 = 0



/// This extension provides a mechanism for displaying UIAlertController
/// from places that are not connected to a UIViewController.  It essentially
/// creates a UIWindow with a transparent root view controller.
///
/// Uses the Objective-C associated object.
extension UIAlertController {
    var alertWindow: UIWindow {
        get {
            return associatedObject(self, key: &alertWindowKey) {
                return UIWindow(frame: UIScreen.mainScreen().bounds)
            }
        }

        set {
            associateObject(self, key: &alertWindowKey, value: newValue)
        }
    }

    func show() {
        self.show(true)
    }


    func show(animated: Bool) {
        let window = alertWindow
        window.rootViewController = UIViewController()

        window.tintColor = UIApplication.sharedApplication().delegate?.window!!.tintColor
        let topWindow = UIApplication.sharedApplication().windows.last
        window.windowLevel = (topWindow?.windowLevel)! + 1

        window.makeKeyAndVisible()
        window.rootViewController?.presentViewController(self, animated: animated, completion: nil)
    }


    public override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)

        self.alertWindow.hidden = true
    }
}
