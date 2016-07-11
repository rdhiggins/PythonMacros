//
//  SyntaxTextStorage.swift
//  PythonTest.Swift
//
//  Created by Rodger Higgins on 6/23/16.
//  Copyright © 2016 Rodger Higgins. All rights reserved.
//

import UIKit


/// A incomplete class for syntax highlighting Python code in a CodeView.
/// Hopefully a good starting point.
class SyntaxTextStorage: BaseTextStorage {
    
    let pythonKeywords: [String] = [
        "and",
        "as",
        "assert",
        "break",
        "class",
        "continue",
        "def",
        "del",
        "elif",
        "else",
        "except",
        "exec",
        "finally",
        "for",
        "from",
        "global",
        "if",
        "import",
        "in",
        "is",
        "lambda",
        "not",
        "or",
        "pass",
        "print",
        "raise",
        "return",
        "try",
        "while",
        "with",
        "yield"
    ]
    
    override func processEditing() {
        let text = string as NSString
        
        setAttributes([
            NSFontAttributeName: UIFont(name: "Menlo", size: 14.0)!,
            NSForegroundColorAttributeName: SyntaxHighlightThemes.Default.plain
        ], range: NSRange(location: 0, length: length))
        
        text.enumerateSubstringsInRange(NSRange(location: 0, length: length), options: .ByWords) {
            [weak self] string, range, _, _ in
            
            guard let string = string else { return }
            
            let keyword: Bool = self?.pythonKeywords.contains(string.lowercaseString) ?? false
            if keyword {
                self?.addAttribute(NSForegroundColorAttributeName, value: SyntaxHighlightThemes.Default.keyword, range: range)
            }
        }
        
        super.processEditing()
    }
}
