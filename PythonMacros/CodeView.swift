//
// CodeView.swift
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


/// A custom UIView based class that contains a custom UITextView with
/// a custom layout manager.  Use this class to show a text file with a line
/// number gutter on the left.
@IBDesignable
class CodeView: UIView {


    /// Property containing the code to display
    @IBInspectable var text: String? {
        set {
            textView?.text = newValue
        }
        get {
            return textView?.text
        }
    }

    /// Property containing the width of the gutter to display the line
    /// numbers in.
    @IBInspectable var gutterWidth: CGFloat = 20.0 {
        didSet {
            textView?.gutterWidth = gutterWidth
            layoutManager?.gutterWidth = gutterWidth
        }
    }


    /// Property containing the width of the gutter border
    @IBInspectable var gutterBorderWidth: CGFloat = 1.0 {
        didSet {
            textView?.gutterStrokeWidth = gutterBorderWidth
        }
    }


    /// Property containing the background color for the gutter
    @IBInspectable var gutterBackgroundColor: UIColor = UIColor.gray {
        didSet {
            textView?.gutterFillColor = gutterBackgroundColor
        }
    }


    /// property containing the color to use for the line numbers
    @IBInspectable var gutterTextColor: UIColor = UIColor.black {
        didSet {
            textView?.gutterTextColor = gutterTextColor
            layoutManager?.textColor = gutterTextColor
        }
    }


    /// Property containing the color og the gutter border
    @IBInspectable var gutterBorderColor: UIColor = UIColor.black {
        didSet {
            textView?.gutterBorderColor = gutterBorderColor
        }
    }


    /// Property containing the color to use for the text displayed
    @IBInspectable var textColor: UIColor? {
        didSet {
            textView?.textColor = textColor
        }
    }


    ///  Property containing the font to use for the code and line numbers
    @IBInspectable var font: UIFont? = UIFont(name: "Menlo", size: 14) {
        didSet {
            textView?.font = font
            layoutManager?.font = font
        }
    }


    /// Property enabling editing support for the text view
    @IBInspectable var canEdit: Bool = true {
        didSet {
            textView?.isEditable = canEdit
        }
    }

    var delegate: UITextViewDelegate? {
        didSet {
            textView?.delegate = delegate
        }
    }


    var textContainer: NSTextContainer!
    var layoutManager: LineNumberLayoutManager!
    var textStorage: NSTextStorage!
    var textView: LineNumberTextView!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    

    /// A private method for setting up this view
    fileprivate func setup() {
        textContainer = NSTextContainer()
        
        layoutManager = LineNumberLayoutManager()
        layoutManager.addTextContainer(textContainer)
        
        textStorage = SyntaxTextStorage()
        textStorage.addLayoutManager(layoutManager)
        
        setupGutterRegion()
        setupTextView()
    }
    

    /// A private method used to setup the gutter region.  This entails
    /// defining the exclusion zone used for the gutter
    fileprivate func setupGutterRegion() {
        let bp = UIBezierPath(rect: CGRect(x: CGFloat(0.0),
                                 y: CGFloat(0.0),
                             width: gutterWidth,
                            height: CGFloat(FLT_MAX)))
        
        self.textContainer.exclusionPaths = [bp]
    }
    

    /// A private method for initializing the textview used.
    fileprivate func setupTextView() {
        textView = LineNumberTextView(frame: self.bounds, textContainer: textContainer)
        textView.text = text
        textView.gutterFillColor = gutterBackgroundColor
        textView.gutterWidth = gutterWidth
        textView.gutterStrokeWidth = gutterBorderWidth
        textView.gutterBorderColor = gutterBorderColor
        textView.font = font
        textView.backgroundColor = UIColor.clear
        textView.isEditable = canEdit
        textView.autocapitalizationType = .none
        textView.autocorrectionType = .no
        setupInputAccessoryView()
        addSubview(textView)
    }

    
    fileprivate func setupInputAccessoryView() {
        let rect = CGRect(x: 0.0, y: 0.0, width: 10.0, height: 44.0)
        let bar = UIToolbar(frame: rect)
        textView.inputAccessoryView = bar
        textView.inputAccessoryView?.sizeToFit()
        
        bar.items = [
            UIBarButtonItem(title: "tab", style: .plain, target: self, action: #selector(self.tab)),
            UIBarButtonItem(title: "undo", style: .plain, target: nil, action: nil),
            UIBarButtonItem(title: "_", style: .plain, target: self, action: #selector(self.underscore)),
            UIBarButtonItem(title: "<", style: .plain, target: self, action: #selector(self.lessThen)),
            UIBarButtonItem(title: ">", style: .plain, target: self, action: #selector(self.greaterThen)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "{", style: .plain, target: self, action: #selector(self.openBrace)),
            UIBarButtonItem(title: "}", style: .plain, target: self, action: #selector(self.closeBrace)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "[", style: .plain, target: self, action: #selector(self.openSquareBrace)),
            UIBarButtonItem(title: "]", style: .plain, target: self, action: #selector(self.closeSquareBrace)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "'", style: .plain, target: self, action: #selector(self.singleQuote)),
            UIBarButtonItem(title: ",", style: .plain, target: self, action: #selector(self.comma)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "(", style: .plain, target: self, action: #selector(self.openParen)),
            UIBarButtonItem(title: ")", style: .plain, target: self, action: #selector(self.closeParen)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "+", style: .plain, target: self, action: #selector(self.plus)),
            UIBarButtonItem(title: "-", style: .plain, target: self, action: #selector(self.minus)),
            UIBarButtonItem(title: "/", style: .plain, target: self, action: #selector(self.divide)),
            UIBarButtonItem(title: "*", style: .plain, target: self, action: #selector(self.multiply)),
            UIBarButtonItem(title: "=", style: .plain, target: self, action: #selector(self.equals)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: ":", style: .plain, target: self, action: #selector(self.colon)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.doneButton(_:)))
        ]
            
        
    }
    
    
    func doneButton(_ barButton: UIBarButtonItem) {
        textView.resignFirstResponder()
    }


    override func layoutSubviews() {
        super.layoutSubviews()
        
        textView?.frame = self.bounds
    }
    
    
    override func resignFirstResponder() -> Bool {
        return textView.resignFirstResponder()
    }
}



extension CodeView {
    func insertString(_ str: String) {
        guard let r = textView.selectedTextRange else { return }

        if r.isEmpty {
            textView.insertText(str)
        } else {
            textView.replace(r, withText: str)
        }
    }
    
    func tab() {
        insertString("    ")
    }
    
    func underscore() {
        insertString("_")
    }
    
    func lessThen() {
        insertString("<")
    }
    
    func greaterThen() {
        insertString(">")
    }
    
    func openBrace() {
        insertString("{")
    }
    
    func closeBrace() {
        insertString("}")
    }
    
    func openSquareBrace() {
        insertString("[")
    }
    
    func closeSquareBrace() {
        insertString("]")
    }
    
    func singleQuote() {
        insertString("'")
    }
    
    func comma() {
        insertString(",")
    }
    
    func openParen() {
        insertString("(")
    }
    
    func closeParen() {
        insertString(")")
    }
    
    func plus() {
        insertString("+")
    }
    
    func minus() {
        insertString("-")
    }
    
    func divide() {
        insertString("/")
    }
    
    func multiply() {
        insertString("*")
    }
    
    func equals() {
        insertString("=")
    }
    
    func colon() {
        insertString(":")
    }
}
