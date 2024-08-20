//
//  ReviseContextViewController.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/7/24.
//

import UIKit

class ReviseContextViewController: UIViewController, StoryboardGenerated {
    static var storyboardName: String = K.Storyboard.main
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var nextBarButtonItem: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textView.becomeFirstResponder()
    }
    
    private func setup() {
        contentView.addDefaultBorder()
        
        textView.delegate = self
        textView.keyboardDismissMode = .interactive
        
//        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(singleTap))
//        textView.addGestureRecognizer(panGesture)
        
        nextBarButtonItem.tintColor = UIColor.transition
        nextBarButtonItem.isEnabled = false
    }
    
    
    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nextAction(_ sender: UIBarButtonItem) {
        guard let text = textView.text else { return }
        
        let controller = UserGeneratedArticleViewController.instantiate()
        controller.inputText = text
        self.navigationController?.pushViewController(controller, animated: true)
    }
}

extension ReviseContextViewController: UITextViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if textView.isFirstResponder {
            textView.resignFirstResponder()
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text ?? ""

        guard let textRange = Range(range, in: currentText) else {
            return false
        }
        
        let updatedText = currentText.replacingCharacters(in: textRange, with: text)

        let isEmpty = updatedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        
        if isEmpty {
            nextBarButtonItem.tintColor = UIColor.transition
            nextBarButtonItem.isEnabled = false
        } else {
            nextBarButtonItem.tintColor = UIColor.title
            nextBarButtonItem.isEnabled = true
        }
        
        return true
    }
    
    @objc func handleTap() {
        textView.resignFirstResponder()
    }
}
