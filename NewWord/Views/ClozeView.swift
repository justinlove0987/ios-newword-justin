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

//    private let inputAccossoryView = InputAccessoryView()

    @IBOutlet weak var inputAccossoryView: InputAccessoryView!
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
        contextTextTextView.resignFirstResponder()
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    func setup() {
        contextTextTextView.text = viewModel?.getContextText()

        addSubview(inputAccossoryView)
        inputAccossoryView.translatesAutoresizingMaskIntoConstraints = false

        setupKeyboardHiding()
    }

    func setupAfterViewInHierarchy() {
        inputViewTopAnchor = inputAccossoryView.topAnchor.constraint(equalTo: topAnchor, constant: frame.height)

        NSLayoutConstraint.activate([
            inputAccossoryView.leadingAnchor.constraint(equalTo: leadingAnchor),
            inputAccossoryView.trailingAnchor.constraint(equalTo: trailingAnchor),
            inputAccossoryView.heightAnchor.constraint(equalToConstant: 50),
            inputViewTopAnchor
        ])
        
        layoutIfNeeded()

        inputAccossoryView.textField.becomeFirstResponder()
    }

    private func setupKeyboardHiding() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

    }

    @objc func keyboardWillShow(sender: NSNotification) {
        guard let userInfo = sender.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
              let superview = superview else { return }

        let keyboardTopY = keyboardFrame.cgRectValue.origin.y
        let safeAreaTop: CGFloat = superview.safeAreaInsets.top
        let newConstant = keyboardTopY - (safeAreaTop + inputAccossoryView.bounds.height)


        let animationDuration = sender.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        let animationCurve = sender.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber
        guard let duration = animationDuration,
                let curve = animationCurve else {
            return
        }

        let curveAnimationOption = UIView.AnimationOptions(rawValue: curve.uintValue)

        UIView.animate(withDuration: duration, delay: 0.0, options: curveAnimationOption, animations: {
            self.inputViewTopAnchor.constant = newConstant
            self.inputAccossoryView.transform = .identity

        }, completion: { completed in

        })


        layoutIfNeeded()


    }



    @objc func keyboardWillHide(notification: NSNotification) {
        let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        let animationCurve = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber
        guard let duration = animationDuration, 
                let curve = animationCurve,
                let superview = superview else {
            return
        }

        let curveAnimationOption = UIView.AnimationOptions(rawValue: curve.uintValue)

        UIView.animate(withDuration: duration, delay: 0.0, options: curveAnimationOption, animations: {
            self.inputViewTopAnchor.constant = self.frame.maxY - self.inputAccossoryView.frame.height - superview.safeAreaInsets.top
            self.inputAccossoryView.transform = .identity

        }, completion: { completed in

        })

        self.layoutIfNeeded()
    }
}

extension ClozeView: ShowCardsSubviewDelegate {}
