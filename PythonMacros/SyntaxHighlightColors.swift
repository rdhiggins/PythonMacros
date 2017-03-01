//
//  SyntaxHighlightColors.swift
//  PythonTest.Swift
//
//  Created by Rodger Higgins on 6/22/16.
//  Copyright © 2016 Rodger Higgins. All rights reserved.
//

import UIKit


/// Enum used to return color values for the codeview.  Currently a incomplete
/// implementation at this point.  Hopefully a good starting point.
enum SyntaxHighlightThemes {
    case `default`
    
    
    var plain: UIColor {
        switch self {
        case .default:
            return UIColor(red:1.00, green:0.98, blue:0.97, alpha:1.00)
        }
    }
    
    var keyword: UIColor {
        switch self {
        case .default:
            return UIColor(red:0.76, green:0.24, blue:0.64, alpha:1.00)
        }
    }
    
    var comments: UIColor {
        switch self {
        case .default:
            return UIColor(red:0.32, green:0.78, blue:0.34, alpha:1.00)
        }
    }
    
    var strings: UIColor {
        switch self {
        case .default:
            return UIColor(red:1.00, green:0.28, blue:0.30, alpha:1.00)
        }
    }
    
    var numbers: UIColor {
        switch self {
        case .default:
            return UIColor(red:0.55, green:0.54, blue:0.99, alpha:1.00)
        }
    }
    
    var attributes: UIColor {
        switch self {
        case .default:
            return UIColor(red:0.31, green:0.43, blue:0.53, alpha:1.00)
        }
    }
    
    var classNames: UIColor {
        switch self {
        case .default:
            return UIColor(red:0.17, green:0.97, blue:0.60, alpha:1.00)
        }
    }
    
    var background: UIColor {
        switch self {
        case .default:
            return UIColor(red:0.01, green:0.01, blue:0.01, alpha:1.00)
        }
    }
    
    var gutterBackground: UIColor {
        switch self {
        case .default:
            return UIColor(red:0.10, green:0.10, blue:0.10, alpha:1.00)
        }
    }
    
    var gutterText: UIColor {
        switch self {
        case .default:
            return UIColor(red:0.57, green:0.57, blue:0.55, alpha:1.00)
        }
    }
    
    var gutterBorder: UIColor {
        switch self {
        case .default:
            return UIColor(red:0.20, green:0.20, blue:0.20, alpha:1.00)
        }
    }
}
