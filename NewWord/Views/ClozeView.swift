//
//  ClozeView.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/6/9.
//

import UIKit

protocol ClozeViewProtocol: AnyObject {
    func tap(from view: ClozeView, _ sender: UITapGestureRecognizer)
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
}

class ClozeView: UIView, NibOwnerLoadable {
    
    enum CardStateType: Int, CaseIterable {
        case question
        case answer
    }
    
    var currentState: CardStateType = .question {
        didSet {
            updateUI()
        }
    }

    @IBOutlet weak var customInputView: InputAccessoryView!
    @IBOutlet weak var contentView: UIView!

    private var customTextView: CustomTextView!

    private var card: CDCard?
    private var clozeViewModel: ClozeViewControllerViewModel?
    
    var inputViewTopAnchor: NSLayoutConstraint!

    var delegate: ClozeViewProtocol?
    
    // MARK: - Lifecycles

    init?(card: CDCard) {
        self.card = card
        super.init(frame: .zero)
        commonInit()
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

    deinit {
        customInputView.textField.resignFirstResponder()
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    private func setup() {
        setupViewModel()
        setupTextView()
        layoutTextView()
        setupInputView()
        setupKeyboardHiding()
        setupGestureRecongnizer()
    }
    
    private func setupViewModel() {
        self.clozeViewModel = ClozeViewControllerViewModel()
        self.clozeViewModel?.card = card
    }
    
    private func layoutTextView() {
        self.addSubview(customTextView)

        customTextView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            customTextView.topAnchor.constraint(equalTo: contentView.topAnchor),
            customTextView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            customTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            customTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ])
    }

    private func setupInputView() {
        addSubview(customInputView)
        customInputView.translatesAutoresizingMaskIntoConstraints = false
        customInputView.textField.delegate = self
    }

    private func setupTextView() {
        guard let text = clozeViewModel?.getContext() else { return }
        let attributedString = NSMutableAttributedString(string: text)
        let textStorage = NSTextStorage(attributedString: attributedString)
        let layoutManager = NSLayoutManager()
        
        textStorage.addLayoutManager(layoutManager)

        let textContainer = NSTextContainer(size: CGSize(width: contentView.frame.width, height: contentView.frame.height))
        textContainer.lineFragmentPadding = 0
        layoutManager.addTextContainer(textContainer)

        customTextView = CustomTextView(frame: contentView.frame, textContainer: textContainer)
        
        guard let clozeRange = clozeViewModel?.getClozeRange(),
              let context = clozeViewModel?.getContext() else {
            return
        }
        
        customTextView.text = context
        customTextView.configureText()
        customTextView.highlightRange(clozeRange)
        customTextView.highlightedRange = clozeRange
    }

    private func setupGestureRecongnizer() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        customTextView.addGestureRecognizer(tap)
    }

    @objc func tapAction(_ sender: UITapGestureRecognizer) {
        delegate?.tap(from: self, sender)
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

    private func updateUI() {
        switch currentState {
        case .question:
            break
        case .answer:
            guard let card = card,
                  let context = customTextView.text,
                  let highlightedRange = customTextView.highlightedRange,
                  let cloze = CoreDataManager.shared.getCloze(from: card),
                  let word = cloze.clozeWord else {
                return
            }
            
            let textAndRnage = clozeViewModel?.replaceRangeWithWord(text: context, range: highlightedRange, word: word)
            
            customTextView.text = textAndRnage?.text
            
            if let range = textAndRnage?.range {
                customTextView.highlightedRange = range
            }
            
            customInputView.isHidden = true
        }
    }
    
    private func commonInit() {
        loadNibContent()
    }
}

// MARK: - Keyboard

extension ClozeView {
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

// MARK: - UITextFieldDelegate

extension ClozeView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        nextState()
        
        _ = delegate?.textFieldShouldReturn(textField)

        return true
    }

}

// MARK: - ShowCardsSubviewDelegate

extension ClozeView: ShowCardsSubviewDelegate {}


