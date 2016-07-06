//
//  EditMacroViewController.swift
//  PythonMacros
//
//  Created by Rodger Higgins on 7/5/16.
//  Copyright © 2016 Rodger Higgins. All rights reserved.
//

import UIKit

class EditMacroViewController: UIViewController {

    @IBOutlet weak var codeView: CodeView!
    @IBOutlet weak var macroSelector: UISegmentedControl!
    
    var macros: [PythonMacro] = []
    var selectedMacroIndex: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupCodeView()

        selectedMacroIndex = 0
        codeView.text = macros[selectedMacroIndex].script?.python
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    private func setupCodeView() {
        self.codeView.backgroundColor = SyntaxHighlightThemes.Default.background
        self.codeView.textColor = SyntaxHighlightThemes.Default.plain
        self.codeView.gutterBackgroundColor = SyntaxHighlightThemes.Default.gutterBackground
        self.codeView.gutterBorderColor = SyntaxHighlightThemes.Default.gutterBorder
        self.codeView.gutterTextColor = SyntaxHighlightThemes.Default.gutterText
    }

    
    @IBAction func macroSelectionChanged(sender: AnyObject) {
        selectMacro(macroSelector.selectedSegmentIndex)
    }
    
    
    func selectMacro(index: Int) {
        if index != selectedMacroIndex {
            macros[selectedMacroIndex].script?.python = codeView.text
            macros[selectedMacroIndex].registerMacro()
            PythonMacroEngine.sharedInstance.checkEngineStatus()
            
            codeView.text = macros[index].script?.python
            selectedMacroIndex = index
        }
    }
}
