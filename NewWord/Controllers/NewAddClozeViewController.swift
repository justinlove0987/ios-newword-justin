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
    let color: UIColor
    var textType: TextType = .word
    
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
    @IBOutlet weak var translateLabel: UILabel!
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
        translationContentView.addDefaultBorder()
        contextContentView.addDefaultBorder()
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
        textContainer.lineFragmentPadding = 0
        layoutManager.addTextContainer(textContainer)
        
        // 創建一個自定義 UITextView 並配置它
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        
        customTextView = AddClozeTextView(frame: textView.frame, textContainer: textContainer)
        customTextView.increaseLineSpacing(UserDefaultsManager.shared.preferredLineSpacing)
        customTextView.isEditable = false
        customTextView.backgroundColor = .clear
        customTextView.font = UIFont.systemFont(ofSize: UserDefaultsManager.shared.preferredFontSize,
                                                weight: .medium)
        customTextView.textColor = UIColor.title
        customTextView.translatesAutoresizingMaskIntoConstraints = false
        customTextView.addGestureRecognizer(tapGesture)
        customTextView.delegate = self
        customTextView.isScrollEnabled = true
        
        self.view.addSubview(customTextView)
        
        NSLayoutConstraint.activate([
            customTextView.topAnchor.constraint(equalTo: textView.topAnchor),
            customTextView.bottomAnchor.constraint(equalTo: textView.bottomAnchor),
            customTextView.leadingAnchor.constraint(equalTo: textView.leadingAnchor),
            customTextView.trailingAnchor.constraint(equalTo: textView.trailingAnchor),
        ])
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
            selectModeButton.setTitle("Word", for: .normal)
        case .sentence:
            selectModeButton.setTitle("Sentence", for: .normal)
        }
    }
    
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        if let _ = customTextView.selectedTextRange {
            customTextView.selectedTextRange = nil
        }
        
        guard let customTextView = gesture.view as? AddClozeTextView else { return }
        var location = gesture.location(in: customTextView)
        
        location.x -= customTextView.textContainerInset.left
        location.y -= customTextView.textContainerInset.top
        
        if let characterIndex = customTextView.characterIndex(at: location) {
            var range: NSRange?
            
            if selectMode == .word {
                if let wordRange = customTextView.wordRange(at: characterIndex) {
                    range = wordRange
                    
                    guard let range = range else { return }
                    
                    clozeWord(range: range)
                }
                
            } else {
                if let sentenceRange =  customTextView.sentenceRangeContainingCharacter(at: characterIndex) {
                    range = sentenceRange
                    
                    guard let range = range else { return }
                    
                    clozeWord(range: range)
                }
            }
        }
    }
    
    private func clozeWord(range: NSRange) {
        if viewModel.containsCloze(range) {
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
            customTextView.increaseLineSpacing(UserDefaultsManager.shared.preferredLineSpacing)

            return
        }
        
        // 獲取點擊的文字
        let text = (customTextView.text as NSString).substring(with: range)

        viewModel.translateEnglishToChinese(text) { result in
            switch result {
            case .success(let translatedSimplifiedText):
                let traditionalText = self.viewModel.convertSimplifiedToTraditional(translatedSimplifiedText)
                
                self.translateLabel.text = traditionalText
                
            case .failure(_):
                break
            }
        }
        
        guard !viewModel.isWhitespace(text) else { return }
        
        let clozeNumber = viewModel.getClozeNumber()
        customTextView.insertNumberImageView(at: range.location, existClozes: viewModel.clozes, with: String(clozeNumber))

        let offset = 1
        let updateRange = viewModel.getUpdatedRange(range: range, offset: offset)
        let textType = viewModel.getTextType(text)
        let newCloze = viewModel.createNewCloze(number: clozeNumber, cloze: text, range: updateRange, selectMode: selectMode, textType: textType)

        viewModel.updateClozeNSRanges(with: updateRange, offset: offset)
        viewModel.appendCloze(newCloze)

        let coloredText = viewModel.calculateColoredTextHeightFraction()
        let coloredMarks = viewModel.createColoredMarks(coloredText)
        
        customTextView.newColorRanges = coloredText
        customTextView.renewTagImages(coloredMarks)
        customTextView.increaseLineSpacing(UserDefaultsManager.shared.preferredLineSpacing)
    }
}

// MARK: - UITextViewDelegate

extension NewAddClozeViewController: UITextViewDelegate {
    // 當文字選擇變化時
    func textViewDidChangeSelection(_ textView: UITextView) {
        // 獲取反白的範圍
        if let selectedRange = textView.selectedTextRange {
            // 獲取範圍的起始和結束位置
            let start = textView.offset(from: textView.beginningOfDocument, to: selectedRange.start)
            let end = textView.offset(from: textView.beginningOfDocument, to: selectedRange.end)
            let selectedText = (textView.text as NSString).substring(with: NSRange(location: start, length: end - start))
            
        }
    }
}
