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
    let number: Int
    let cloze: String
    var range: NSRange
    let color: UIColor
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
    @IBOutlet weak var hintLabel: UILabel!
    @IBOutlet weak var selectModeButton: UIButton!
    
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
    
    // MARK: - Helpers
    
    private func setup() {
        setupViewModel()
        setupTextView()
        setupCumstomTextView()
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
        let attributedString = NSMutableAttributedString(string: textView.text)
        
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
        customTextView.textColor = .white
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
    
    @IBAction func segmentedAction(_ sender: UISegmentedControl) {
        
    }
    
    @IBAction func saveAction(_ sender: Any) {
        guard let text = customTextView.text else { return }
        
        viewModel.saveCloze(text)
        
        navigationController?.popViewController(animated: true)
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
        // 檢查是否有文字被反白選中
        if let _ = customTextView.selectedTextRange {
            // 取消文字的反白選中狀態
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
                    
//                    if viewModel.containsCloze(range) {
//                        let updatedRange = NSRange(location: range.location-1, length: range.length)
//                        
//                        customTextView.removeNumberImageView(at: updatedRange.location)
//                        viewModel.removeCloze(range)
//                        viewModel.updateNSRange(with: updatedRange, offset: -1)
//                        customTextView.highlightedRanges = viewModel.getNSRanges()
//                        return
//                    }
//                    
//                    // 獲取點擊的文字
//                    let text = (customTextView.text as NSString).substring(with: range)
//
//                    viewModel.translateEnglishToChinese(text) { result in
//                        switch result {
//                        case .success(let translatedSimplifiedText):
//                            let traditionalText = self.viewModel.convertSimplifiedToTraditional(translatedSimplifiedText)
//                            
//                            self.translateLabel.text = traditionalText
//                            self.hintLabel.text = traditionalText
//                            
//                        case .failure(_):
//                            break
//                        }
//                    }
//                    
//                    guard !viewModel.isWhitespace(text) else { return }
//                    
//                    let clozeNumber = viewModel.getClozeNumber()
//                    let offset = 1
//                    let updateRange = NSRange(location: range.location+offset, length: range.length)
//                    let newCloze = NewAddCloze(number: clozeNumber, cloze: text, range: updateRange)
//                    
//                    customTextView.insertNumberImageView(at: range.location, with: String(clozeNumber), scale: 0.8)
//                    
//                    viewModel.appendCloze(newCloze)
//                    viewModel.updateNSRange(with: newCloze.range, offset: offset)
//                    
//                    customTextView.highlightedCoverRanges = [newCloze.range]
//                    
//                    customTextView.increaseLineSpacing(UserDefaultsManager.shared.preferredLineSpacing)
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
            let updatedRange = NSRange(location: range.location-1, length: range.length)
            
            customTextView.removeNumberImageView(at: updatedRange.location)
            viewModel.removeCloze(range)
            viewModel.updateNSRange(with: updatedRange, offset: -1)
            customTextView.highlightedRanges = viewModel.getNSRanges()
            return
        }
        
        // 獲取點擊的文字
        let text = (customTextView.text as NSString).substring(with: range)

        viewModel.translateEnglishToChinese(text) { result in
            switch result {
            case .success(let translatedSimplifiedText):
                let traditionalText = self.viewModel.convertSimplifiedToTraditional(translatedSimplifiedText)
                
                self.translateLabel.text = traditionalText
                self.hintLabel.text = traditionalText
                
            case .failure(_):
                break
            }
        }
        
        guard !viewModel.isWhitespace(text) else { return }
        
        let clozeNumber = viewModel.getClozeNumber()
        let offset = 1
        let updateRange = NSRange(location: range.location+offset, length: range.length)
        
        var newCloze: NewAddCloze
        
        if selectMode == .sentence {
            newCloze = NewAddCloze(number: clozeNumber, cloze: text, range: updateRange, color: UIColor.clozeBlueText)
        } else {
            newCloze = NewAddCloze(number: clozeNumber, cloze: text, range: updateRange, color: .red)
        }
        
        customTextView.insertNumberImageView(at: range.location, with: String(clozeNumber))
        
        viewModel.appendCloze(newCloze)
        viewModel.updateNSRange(with: newCloze.range, offset: offset)
        
        customTextView.highlightedRanges = viewModel.getNSRanges()
        
        let information = viewModel.createChracterGradientInformation()
        customTextView.newColorRanges = information
        
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
