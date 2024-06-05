//
//  AddClozeViewController.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/6/4.
//

import UIKit

class AddClozeViewController: UIViewController, StoryboardGenerated {
    
    static var storyboardName: String = K.Storyboard.main
    
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addContextRevisionInputAccessoryView()
    }
    
    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
    }
    
    private func addContextRevisionInputAccessoryView() {
        let view = ContextRevisionInputAccessoryView()
        view.delegate = self
        textView.inputAccessoryView = view
        textView.becomeFirstResponder()
    }
    
}

extension AddClozeViewController: ContextRevisionInputAccessoryViewDelegate {
    func didTapCleanChineseButton() {
        textView.text
        print(textView.text)
    }
}
