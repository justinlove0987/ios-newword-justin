//
//  ClozeView.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/6/9.
//

import UIKit

class ClozeView: UIView, NibOwnerLoadable, ContextRevisionInputAccessoryViewDelegate, UITextFieldDelegate {
    func didTapCleanChineseButton() {
        
    }
    
    enum CardStateType: Int, CaseIterable {
        case question
        case answer
    }
    
    var currentState: CardStateType = .question
    
    private let dummyTextField = UITextField()
//    private let inputAccossoryView = InputAccessoryView()
    
    @IBOutlet weak var contextTextTextView: UITextView!
    
    private var card: CDCard?
    private var viewModel: ClozeViewViewModel?
    
    init(card: CDCard, viewModel: ClozeViewViewModel) {
        super.init(frame: .zero)
        commonInit()
        self.card = card
        self.viewModel = viewModel
        setup()
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        loadNibContent()
    }
    
    private func setup() {
        contextTextTextView.text = viewModel?.getContextText()
        
//        let view = InputAccessoryView()
//        
//        addSubview(<#T##view: UIView##UIView#>)
//        view.frame = CGRect(x: 0, y: 0, width: 0, height: 50)
        
//        dummyTextField.inputView = view
//        dummyTextField.becomeFirstResponder()
        
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(keyboardWillShow(notification:)),
//                                               name: UIResponder.keyboardWillShowNotification,
//                                               object: nil)
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(keyboardWillHide(notification:)),
//                                               name: UIResponder.keyboardWillHideNotification,
//                                               object: nil)
        
        
        
//        addSubview(dummyTextField)
        
        
//        contextTextTextView.inputView = view
//        view.frame = CGRect(x: 0, y: 0, width: 0, height: 50)
        let view = InputAccessoryView()
        addSubview(dummyTextField)
        view.frame = CGRect(x: 0, y: 0, width: 0, height: 50)
//        view.delegate = self
        dummyTextField.inputAccessoryView = view
        dummyTextField.becomeFirstResponder()
        view.becomeFirstResponder()

    }
    
    private lazy var accessoryTextField: UITextField = {
            let textField = UITextField()
            textField.borderStyle = .roundedRect
            textField.backgroundColor = .clear
            textField.returnKeyType = .done
            textField.delegate = self
            textField.autocorrectionType = .no
            textField.spellCheckingType = .no
            textField.translatesAutoresizingMaskIntoConstraints = false
            textField.layer.borderColor = UIColor.black.cgColor
            return textField
        }()

    func createAccessoryInputView(_ accessoryTextField: UITextField) -> UIView {
            let containerView = UIView()
            containerView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: 70)
            containerView.addSubview(accessoryTextField)
            NSLayoutConstraint.activate([
                accessoryTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
                accessoryTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
                accessoryTextField.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
                accessoryTextField.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8),
            ])
            containerView.translatesAutoresizingMaskIntoConstraints = false
            containerView.backgroundColor = .white
            return containerView
        }
    
    @objc func keyboardWillShow(notification: NSNotification) {
           
//        inputAccossoryView.textField.becomeFirstResponder()
       }
    
}

extension ClozeView: ShowCardsSubviewDelegate {

    
}
