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
    @IBOutlet weak var contextTextView: UITextView!
    @IBOutlet weak var tableView: UITableView!

    private var customTextView: CustomTextView!

    private var card: CDCard?
    private var clozeViewModel: ClozeViewControllerViewModel?
    private var clzoe: String?

    private var dataSource: [[ClozeWord]] = []

    var delegate: ClozeViewProtocol?

    var inputViewTopAnchor: NSLayoutConstraint!

    init?(card: CDCard) {
        self.card = card
        self.clozeViewModel = ClozeViewControllerViewModel()
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

    private func commonInit() {
        loadNibContent()
    }

    deinit {
        customInputView.textField.resignFirstResponder()
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    private func setup() {
        setupTextView()
        setupInputView()
        setupKeyboardHiding()
        setupGestureRecongnizer()
    }

    private func setupTextView() {
        guard let card = card,
              let context = CoreDataManager.shared.getContext(from: card),
              let number = CoreDataManager.shared.getClozeNumber(from: card),
              let text = clozeViewModel?.retainMarker(number: number, text: context) else {
            return
        }

        setupCumstomTextView(number: number, text: text)

        contextTextView.isHidden = true
    }

    private func setupInputView() {
        addSubview(customInputView)
        customInputView.translatesAutoresizingMaskIntoConstraints = false
        customInputView.textField.delegate = self
    }

    private func setupCumstomTextView(number: Int, text: String) {
        let attributedString = NSMutableAttributedString(string: text)

        // 創建一個 Text Storage 和 Layout Manager
        let textStorage = NSTextStorage(attributedString: attributedString)
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)

        // 創建一個 Text Container 並配置它
        let textContainer = NSTextContainer(size: CGSize(width: contextTextView.frame.width, height: contextTextView.frame.height))
        textContainer.lineFragmentPadding = 0
        layoutManager.addTextContainer(textContainer)

        // 創建一個自定義 UITextView 並配置它
        customTextView = CustomTextView(frame: contextTextView.frame, textContainer: textContainer)
        customTextView.isEditable = false
        customTextView.isScrollEnabled = true
        customTextView.backgroundColor = .clear
        customTextView.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        customTextView.textColor = .white

        self.addSubview(customTextView)

        customTextView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            customTextView.topAnchor.constraint(equalTo: contextTextView.topAnchor),
            customTextView.bottomAnchor.constraint(equalTo: contextTextView.bottomAnchor),
            customTextView.leadingAnchor.constraint(equalTo: contextTextView.leadingAnchor),
            customTextView.trailingAnchor.constraint(equalTo: contextTextView.trailingAnchor),
        ])

        if let textAndRange = clozeViewModel?.removeMarkerAndReplaceWithWhitespace(number: number, text: text),
           let range = textAndRange.range {
            
            // 創建屬性字典
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 18, weight: .medium),
                .foregroundColor: UIColor.white
            ]

            // 創建 attributed string
            let attributedString = NSMutableAttributedString(string: textAndRange.text, attributes: attributes)
            
            attributedString.addAttributes([.foregroundColor: UIColor.blue], range: range)

            // 設置其他屬性
            customTextView.isEditable = false
            customTextView.isScrollEnabled = true
            customTextView.backgroundColor = .clear
            
            // 設置 customTextView 的 attributedText
            customTextView.attributedText = attributedString
            
//            customTextView.text = textAndRange.text
            customTextView.highlightedRange = range
        }
    }

    private func setupTableView() {
        guard let card = card,
              let context = CoreDataManager.shared.getContext(from: card),
              let number = CoreDataManager.shared.getClozeNumber(from: card) else {
            return
        }

        tableView.register(ContextCell.self, forCellReuseIdentifier: "ContextCell")

        let sentences = clozeViewModel!.convertTextIntoSentences(text: context)


        let newClozeWords = sentences.map { sentence in
            sentence.map { word in
                var word = word

                if let result = clozeViewModel!.extractNumberAndCoreWord(from: word.text) {

                    let newText = result.1
                    let extractedNumber = result.0

                    if number == extractedNumber {
                        word.clozeNumber = extractedNumber
                        word.selected = true
                    }

                    word.text = newText
                }

                return word
            }
        }

        dataSource = newClozeWords
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

extension ClozeView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContextCell", for: indexPath) as! ContextCell

        cell.configureCell(with: dataSource[indexPath.row])

        return cell
    }
}

// MARK: - ShowCardsSubviewDelegate

extension ClozeView: ShowCardsSubviewDelegate {}


