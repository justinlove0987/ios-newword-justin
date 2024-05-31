//
//  ReviseNameViewController.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/5/30.
//

import UIKit

class ReviseNameViewController: UIViewController, StoryboardGenerated {
    
    static var storyboardName: String = "Main"
    
    @IBOutlet weak var textField: UITextField!
    
    var previousName: String? = ""
    
    var renameAction: ((_ name: String) -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.text = previousName
    }
    
    
    @IBAction func saveAction(_ sender: UIButton) {
        guard let renameAction else { return }
        renameAction(textField.text!)
        self.navigationController?.popViewController(animated: true)
    }

}
