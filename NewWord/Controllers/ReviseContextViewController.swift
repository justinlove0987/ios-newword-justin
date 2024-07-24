//
//  ReviseContextViewController.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/7/24.
//

import UIKit

class ReviseContextViewController: UIViewController, StoryboardGenerated {
    static var storyboardName: String = K.Storyboard.main
    
    var text: String?
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 15
        
        textView.delegate = self
        textView.keyboardDismissMode = .interactive
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleTap))
        textView.addGestureRecognizer(panGesture)
    }
    
    
    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nextAction(_ sender: UIBarButtonItem) {
        let controller = NewAddClozeViewController.instantiate()
        self.navigationController?.pushViewController(controller, animated: true)
    }
}

extension ReviseContextViewController: UITextViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if textView.isFirstResponder {
            textView.resignFirstResponder()
        }
    }
    
    @objc func handleTap() {
        textView.resignFirstResponder()
    }
}
