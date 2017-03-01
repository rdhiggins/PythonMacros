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


    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        saveMacro(selectedMacroIndex)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    /// A private method used to setup custom attributes for the codeview.
    fileprivate func setupCodeView() {
        self.codeView.backgroundColor = SyntaxHighlightThemes.default.background
        self.codeView.textColor = SyntaxHighlightThemes.default.plain
        self.codeView.gutterBackgroundColor = SyntaxHighlightThemes.default.gutterBackground
        self.codeView.gutterBorderColor = SyntaxHighlightThemes.default.gutterBorder
        self.codeView.gutterTextColor = SyntaxHighlightThemes.default.gutterText
    }

    
    @IBAction func macroSelectionChanged(_ sender: AnyObject) {
        saveMacro(macroSelector.selectedSegmentIndex)
        selectMacro(macroSelector.selectedSegmentIndex)
    }
    

    /// Method used to retieve the python script from the codeview.  Update
    /// the PythonMacro.  And then load the new Macro value.
    ///
    /// - parameter index: The index of the new PythonMacro to load into
    /// the CodeView
    func selectMacro(_ index: Int) {
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
    func saveMacro(_ index: Int) {
        macros[selectedMacroIndex].script?.python = codeView.text
        macros[selectedMacroIndex].registerMacro()
    }
}
