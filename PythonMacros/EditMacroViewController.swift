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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupCodeView()
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
