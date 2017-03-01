//
//  BaseTextStorage.swift
//  PythonTest.Swift
//
//  Created by Rodger Higgins on 6/23/16.
//  Copyright © 2016 Rodger Higgins. All rights reserved.
//

import UIKit

/// A class used as a base class for declaring custom NSTextStorage classes.
/// This class contains generic implementations of methods required in 
/// any NSTextStorage subclasses.
class BaseTextStorage: NSTextStorage {
    
    fileprivate let storage = NSMutableAttributedString()
    
    override var string: String {
        return storage.string
    }
    
    override func attributes(at location: Int, effectiveRange range: NSRangePointer?) -> [String : Any] {
        return storage.attributes(at: location, effectiveRange: range)
    }
    
    
    override func replaceCharacters(in range: NSRange, with str: String) {
        let beforeLength = length
        storage.replaceCharacters(in: range, with: str)
        edited(.editedCharacters, range: range, changeInLength: length - beforeLength)
    }
    

    override func setAttributes(_ attrs: [String : Any]?, range: NSRange) {
        storage.setAttributes(attrs, range: range)
        edited(.editedAttributes, range: range, changeInLength: 0)
    }
}
