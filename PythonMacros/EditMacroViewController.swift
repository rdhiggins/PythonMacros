//
//  EditMacroViewController.swift
//  PythonMacros
//
//  Created by Rodger Higgins on 7/5/16.
//  Copyright © 2016 Rodger Higgins. All rights reserved.
//

import UIKit


/// View controller class used for editing python macros.
class EditMacroViewController: UIViewController {

    @IBOutlet weak var codeView: CodeView!
    @IBOutlet weak var macroSelector: UISegmentedControl!

    /// Property that contains the array of PythonMacro object to edit.
    /// please set from segue...
    var macros: [PythonMacro] = []

    /// Property containing the currently selected/editting PythonMacro
    var selectedMacroIndex: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupCodeView()

        selectedMacroIndex = 0
        codeView.text = macros[selectedMacroIndex].script?.python
    }


    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        saveMacro(selectedMacroIndex)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    /// A private method used to setup custom attributes for the codeview.
    private func setupCodeView() {
        self.codeView.backgroundColor = SyntaxHighlightThemes.Default.background
        self.codeView.textColor = SyntaxHighlightThemes.Default.plain
        self.codeView.gutterBackgroundColor = SyntaxHighlightThemes.Default.gutterBackground
        self.codeView.gutterBorderColor = SyntaxHighlightThemes.Default.gutterBorder
        self.codeView.gutterTextColor = SyntaxHighlightThemes.Default.gutterText
    }

    
    @IBAction func macroSelectionChanged(sender: AnyObject) {
        saveMacro(macroSelector.selectedSegmentIndex)
        selectMacro(macroSelector.selectedSegmentIndex)
    }
    

    /// Method used to retieve the python script from the codeview.  Update
    /// the PythonMacro.  And then load the new Macro value.
    ///
    /// - parameter index: The index of the new PythonMacro to load into
    /// the CodeView
    func selectMacro(index: Int) {
        if index != selectedMacroIndex {
            codeView.text = macros[index].script?.python
            selectedMacroIndex = index
        }
    }


    /// Method used to save the python script in the CodeView back into
    /// its matching PythonMacro object.  The new script is then loaded back
    /// into the CPython runtime.
    ///
    /// - parameter index: The index of the PythonMacro to save.
    func saveMacro(index: Int) {
        macros[selectedMacroIndex].script?.python = codeView.text
        macros[selectedMacroIndex].registerMacro()
    }
}
