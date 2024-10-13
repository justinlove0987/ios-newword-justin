//
//  PracticeClozeView.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/9/27.
//

import UIKit

protocol PracticeClozeViewDelegate: AnyObject {
    func didPressReturnInTextField(_ textField: UITextField)
}

class PracticeClozeView: UIView, NibOwnerLoadable {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var clozeLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var nativeLanguageTranslationLabel: UILabel!
    
    weak var delegate: PracticeClozeViewDelegate?
    
    var tapGesture: UITapGestureRecognizer?
    
    var practice: CDPractice? {
        didSet {
            updateUI()
        }
    }
    
    var currentState: CardStateType = .question {
        didSet {
            updateUI()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNibContent()
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadNibContent()
        setup()
    }
    
    private func setup() {
        textField.delegate = self
    }
    
    private func updateUI() {
        guard let article = practice?.serverProviededContent?.article,
              let text = article.text,
              let tag = practice?.userGeneratedContent?.userGeneratedContextTag,
              let nativeLanguageTranslation = tag.translation,
              let range = tag.range
        else {
            return
        }
        
        textView.text = article.text
        clozeLabel.text = tag.text
        
        switch currentState {
        case .question:
            clozeLabel.isHidden = true
            
            nativeLanguageTranslationLabel.text = nativeLanguageTranslation
            
            let attributedText = textView.highlightText(text, in: range)
            textView.attributedText = attributedText
            textView.scrollToRange(range)
            textView.applyTextColor(.clozeBlueText, to: range)
            
            textField.becomeFirstResponder()
            
        case .answer:
            clozeLabel.isHidden = true
            
            textField.placeholder = ""
            textField.isUserInteractionEnabled = false
            
            let attributedText = textView.highlightText(text, in: range)
            textView.attributedText = attributedText
            textView.scrollToRange(range)
            textView.applyTextColor(.title, to: range)
        }
    }
    
    private func addTapGestureRecognizer() {
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        addGestureRecognizer(tapGesture!)
    }
    
    private func removeGestureRecognizer() {
        removeGestureRecognizer(tapGesture!)
        tapGesture = nil
    }
    
    @objc private func dismissKeyboard() {
        if textField.isFirstResponder {
            textField.resignFirstResponder()
        }
    }
}

extension PracticeClozeView: ShowCardsSubviewDelegate {
    enum CardStateType: Int, CaseIterable {
        case question
        case answer
    }
}

extension PracticeClozeView: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        addTapGestureRecognizer()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        removeGestureRecognizer()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        delegate?.didPressReturnInTextField(textField)
        
        currentState = .answer
        
        return true
    }
}
