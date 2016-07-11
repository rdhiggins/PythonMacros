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
    
    private let storage = NSMutableAttributedString()
    
    override var string: String {
        return storage.string
    }
    
    override func attributesAtIndex(location: Int, effectiveRange range: NSRangePointer) -> [String : AnyObject] {
        return storage.attributesAtIndex(location, effectiveRange: range)
    }
    
    
    override func replaceCharactersInRange(range: NSRange, withString str: String) {
        let beforeLength = length
        storage.replaceCharactersInRange(range, withString: str)
        edited(.EditedCharacters, range: range, changeInLength: length - beforeLength)
    }
    

    override func setAttributes(attrs: [String : AnyObject]?, range: NSRange) {
        storage.setAttributes(attrs, range: range)
        edited(.EditedAttributes, range: range, changeInLength: 0)
    }
}
