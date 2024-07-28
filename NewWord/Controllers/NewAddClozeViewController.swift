//
//  NewAddClozeViewController.swift
//  NewWord
//
//  Created by justin on 2024/6/30.
//

import UIKit
import NaturalLanguage
import MLKitTranslate

struct NewAddCloze {
    enum TextType {
        case word
        case sentence
        case article
    }
    
    let number: Int
    let text: String
    var range: NSRange
    let tagColor: UIColor
    let contentColor: UIColor
    var textType: TextType = .word
    let hint: String
    
    func getTagIndex(in text: String) -> String.Index? {
        let location = range.location - 1

        if let stringIndex = text.index(text.startIndex, offsetBy: location, limitedBy: text.endIndex) {
            return stringIndex
        }
        
        return nil
    }
}

class NewAddClozeViewController: UIViewController, StoryboardGenerated {
    
    // MARK: - Properties
    
    enum SelectMode: Int, CaseIterable {
        case word
        case sentence
    }
    
    static var storyboardName: String = K.Storyboard.main
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var originalTextLabel: UILabel!
    @IBOutlet weak var translatedTextLabel: UILabel!
    @IBOutlet weak var selectModeButton: UIButton!
    @IBOutlet var translationContentView: UIView!
    @IBOutlet weak var contextContentView: UIView!
    
    var inputText: String?
    
    private var customTextView: AddClozeTextView!
    private var viewModel: NewAddClozeViewControllerViewModel!
    
    private var selectMode: SelectMode = .word {
        didSet {
            updateSelectModeUI()
        }
    }
    
    // MARK: - Lifecycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupProperties()
    }
    
    // MARK: - Helpers
    
    private func setup() {
        setupProperties()
        setupViewModel()
        setupTextView()
        setupCumstomTextView()
    }
    
    private func setupProperties() {
        translationContentView.addDefaultBorder(maskedCorners: [.layerMinXMinYCorner, .layerMaxXMinYCorner])
        contextContentView.addDefaultBorder(maskedCorners: [.layerMinXMaxYCorner, .layerMaxXMaxYCorner])

        contextContentView.layer.zPosition = 0
        translationContentView.layer.zPosition = 1
        
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    private func setupViewModel() {
        viewModel = NewAddClozeViewControllerViewModel()
    }
    
    private func setupTextView() {
        textView.isEditable = false
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        textView.addGestureRecognizer(tapGesture)
        textView.isHidden = true
    }
    
    private func setupCumstomTextView() {
        guard let inputText else { return }

        let attributedString = NSMutableAttributedString(string: inputText)
        
        // 創建一個 Text Storage 和 Layout Manager
        let textStorage = NSTextStorage(attributedString: attributedString)
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)
        
        // 創建一個 Text Container 並配置它
        let textContainer = NSTextContainer(size: CGSize(width: textView.frame.width, height: textView.frame.height))
        layoutManager.addTextContainer(textContainer)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))

        customTextView = AddClozeTextView(frame: textView.frame, textContainer: textContainer)

        customTextView.isEditable = false
        customTextView.backgroundColor = .clear
        customTextView.delegate = self
        customTextView.translatesAutoresizingMaskIntoConstraints = false
        customTextView.addGestureRecognizer(tapGesture)
        customTextView.setProperties()
        

        self.view.addSubview(customTextView)
        
        NSLayoutConstraint.activate([
            customTextView.topAnchor.constraint(equalTo: contextContentView.topAnchor, constant: 20),
            customTextView.bottomAnchor.constraint(equalTo: contextContentView.bottomAnchor, constant: -20),
            customTextView.leadingAnchor.constraint(equalTo: contextContentView.leadingAnchor, constant: 20),
            customTextView.trailingAnchor.constraint(equalTo: contextContentView.trailingAnchor, constant: -20),
        ])
        
        customTextView.contentSize = CGSize(width: customTextView.frame.width, height: customTextView.frame.height + 50)
    }
    
    // MARK: - Actions
    
    @IBAction func previousAction(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func confirmAction(_ sender: UIBarButtonItem) {
        guard var text = customTextView.text else { return }
        
        text = viewModel.removeAllTags(in: text)
        viewModel.saveCloze(text)
        
        navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func settingAction(_ sender: UIButton) {
        let controller = TagSettingViewController.instantiate()
        
        navigationController?.present(controller, animated: true)
    }
    
    @IBAction func selectModeAction(_ sender: UIButton) {
        let currentSelectModeRawValue = selectMode.rawValue
        let isLastMode = currentSelectModeRawValue + 1 ==  SelectMode.allCases.count
        
        if isLastMode {
            selectMode = SelectMode(rawValue: 0)!
        } else {
            selectMode = SelectMode(rawValue: currentSelectModeRawValue + 1)!
        }
    }
    
    private func updateSelectModeUI() {
        switch selectMode {
        case .word:
            selectModeButton.setTitle("單字", for: .normal)
        case .sentence:
            selectModeButton.setTitle("句子", for: .normal)
        }
    }
    
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        guard !customTextView.isTextSelected() else {
            customTextView.selectedTextRange = nil
            customTextView.setProperties()
            return
        }

        guard let customTextView = gesture.view as? AddClozeTextView else { return }

        var location = gesture.location(in: customTextView)
        location.x -= customTextView.textContainerInset.left
        location.y -= customTextView.textContainerInset.top
        
        if let characterIndex = customTextView.characterIndex(at: location) {
            switch selectMode {
            case .word:
                if let wordRange = customTextView.wordRange(at: characterIndex) {
                    clozeWord(range: wordRange)
                }
            case .sentence:
                if let sentenceRange =  customTextView.sentenceRangeContainingCharacter(at: characterIndex) {
                    clozeWord(range: sentenceRange)
                }
            }
        }
    }

    private func clozeWord(range: NSRange) {
        // 獲取點擊的文字
        let text = (customTextView.text as NSString).substring(with: range)
        let textWithoutFFFC = text.removeObjectReplacementCharacter()

        guard !text.startsWithObjectReplacementCharacter() else { return }
        guard !viewModel.isWhitespace(text) else { return }
        guard !viewModel.containsCloze(range) else {
            viewModel.removeCloze(range)

            if !viewModel.hasDuplicateClozeLocations(with: range) {
                let updatedRange = NSRange(location: range.location-1, length: range.length)
                customTextView.removeNumberImageView(at: updatedRange.location)
                viewModel.updateClozeNSRanges(with: updatedRange, offset: -1)
            }

            let coloredText = viewModel.calculateColoredTextHeightFraction()
            let coloredMarks = viewModel.createColoredMarks(coloredText)

            customTextView.newColorRanges = coloredText
            customTextView.renewTagImages(coloredMarks)
            customTextView.setProperties()

            return
        }

        viewModel.translateEnglishToChinese(textWithoutFFFC) { result in
            switch result {
            case .success(let translatedSimplifiedText):
                let translatedTraditionalText = self.viewModel.convertSimplifiedToTraditional(translatedSimplifiedText)

                self.updateTranslationLabels(originalText: textWithoutFFFC, translatedText: translatedTraditionalText)
                self.updateCloze(with: range, text: text, hint: translatedTraditionalText)
                self.updateCustomTextView()


            case .failure(_):
                self.updateCloze(with: range, text: text, hint: "")
                self.updateCustomTextView()
            }
        }
    }

    private func updateTranslationLabels(originalText: String, translatedText: String) {
        self.originalTextLabel.text = originalText
        self.translatedTextLabel.text = translatedText
        self.originalTextLabel.numberOfLines = 0
        self.translatedTextLabel.numberOfLines = 0

        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }

    private func updateCloze(with range: NSRange, text: String, hint: String) {
        let clozeNumber = self.viewModel.getClozeNumber()
        self.customTextView.insertNumberImageView(at: range.location, existClozes: self.viewModel.clozes, with: String(clozeNumber))

        let offset = 1
        let updateRange = self.viewModel.getUpdatedRange(range: range, offset: offset)
        let textType = self.viewModel.getTextType(text)
        let newCloze = self.viewModel.createNewCloze(number: clozeNumber, cloze: text, range: updateRange, selectMode: self.selectMode, textType: textType, hint: hint)

        self.viewModel.updateClozeNSRanges(with: updateRange, offset: offset)
        self.viewModel.appendCloze(newCloze)
    }

    private func updateCustomTextView() {
        let coloredText = self.viewModel.calculateColoredTextHeightFraction()
        let coloredMarks = self.viewModel.createColoredMarks(coloredText)

        self.customTextView.newColorRanges = coloredText
        self.customTextView.renewTagImages(coloredMarks)
        self.customTextView.setProperties()
    }
    
    @objc func appDidBecomeActive() {
        updateCustomTextView()
    }
    
    deinit {
        // 移除觀察者
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    }
}

extension NewAddClozeViewController: UITextViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView == customTextView {
            self.originalTextLabel.numberOfLines = 1
            self.translatedTextLabel.numberOfLines = 1

            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }
}
