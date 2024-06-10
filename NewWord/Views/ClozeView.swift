//
//  ClozeView.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/6/9.
//

import UIKit

class ClozeView: UIView, NibOwnerLoadable {
    
    enum CardStateType: Int, CaseIterable {
        case question
        case answer
    }
    
    var currentState: CardStateType = .question

    @IBOutlet weak var customInputView: InputAccessoryView!
    @IBOutlet weak var contextTextTextView: UITextView!
    
    private var card: CDCard?
    private var viewModel: ClozeViewViewModel?

    var inputViewTopAnchor: NSLayoutConstraint!

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
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
        setup()
    }

    private func commonInit() {
        loadNibContent()
    }

    deinit {
        customInputView.textField.resignFirstResponder()
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    func setup() {
        contextTextTextView.text = viewModel?.getContextText()
        addSubview(customInputView)
        customInputView.translatesAutoresizingMaskIntoConstraints = false
        setupKeyboardHiding()

        customInputView.textField.delegate = self
    }

    func setupAfterSubviewInHierarchy() {
        guard let superview = superview else { return }

        inputViewTopAnchor = customInputView.topAnchor.constraint(equalTo: topAnchor, constant: self.frame.maxY - self.customInputView.frame.height - superview.safeAreaInsets.top)

        NSLayoutConstraint.activate([
            customInputView.leadingAnchor.constraint(equalTo: leadingAnchor),
            customInputView.trailingAnchor.constraint(equalTo: trailingAnchor),
            customInputView.heightAnchor.constraint(equalToConstant: 50),
            inputViewTopAnchor
        ])
        
        layoutIfNeeded()

        customInputView.textField.becomeFirstResponder()
    }

    private func setupKeyboardHiding() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func keyboardWillShow(sender: NSNotification) {
        guard let userInfo = sender.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
              let superview = superview,
              let duration = sender.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
              let curve = sender.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber else {
            return
        }

        let keyboardTopY = keyboardFrame.cgRectValue.origin.y
        let safeAreaTop: CGFloat = superview.safeAreaInsets.top
        let endConstant = keyboardTopY - (safeAreaTop + customInputView.bounds.height)
        let curveAnimationOption = UIView.AnimationOptions(rawValue: curve.uintValue)

        self.inputViewTopAnchor.constant = endConstant

        UIView.animate(withDuration: duration, delay: 0.0, options: curveAnimationOption) {
            self.customInputView.transform = .identity
        }

        layoutIfNeeded()
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
                let curve = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber,
                let superview = superview else {
            return
        }

        let curveAnimationOption = UIView.AnimationOptions(rawValue: curve.uintValue)

        self.inputViewTopAnchor.constant = self.frame.maxY - self.customInputView.frame.height - superview.safeAreaInsets.top

        UIView.animate(withDuration: duration, delay: 0.0, options: curveAnimationOption, animations: {
            self.customInputView.transform = .identity

        }, completion: { completed in

        })

        layoutIfNeeded()
    }
}

extension ClozeView: ShowCardsSubviewDelegate {}

extension ClozeView: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()

        return true
    }

}
