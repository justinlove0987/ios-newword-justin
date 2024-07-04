//
//  NewAddClozeViewController.swift
//  NewWord
//
//  Created by justin on 2024/6/30.
//

import UIKit
import NaturalLanguage

struct NewAddCloze {
    let number: Int
    let cloze: String
    var range: NSRange
}

class NewAddClozeViewController: UIViewController, StoryboardGenerated {
    
    static var storyboardName: String = K.Storyboard.main
    
    @IBOutlet weak var textView: UITextView!
    private var customTextView: AddClozeTextView!
    private var viewModel: NewAddClozeViewControllerViewModel!
    
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
        // textView.text = "a1 b2 c3 d4 e5 f6 g7 h8 i9 j10 k11"
//        textView.text = "dog cat."
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
        customTextView.isEditable = false
//        customTextView.isScrollEnabled = true
        customTextView.backgroundColor = .clear
        customTextView.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        customTextView.textColor = .white
        customTextView.translatesAutoresizingMaskIntoConstraints = false
        customTextView.addGestureRecognizer(tapGesture)
        customTextView.delegate = self
        
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
    
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        guard let customTextView = gesture.view as? AddClozeTextView else { return }
        var location = gesture.location(in: customTextView)
        
        location.x -= customTextView.textContainerInset.left
        location.y -= customTextView.textContainerInset.top
        
        if let characterIndex = customTextView.characterIndex(at: location),
           let wordRange = customTextView.wordRange(at: characterIndex) {
            
            // 獲取點擊的單字
            let word = (customTextView.text as NSString).substring(with: wordRange)
            
            // 判斷點擊的單字是否有藍色背景
            //            if customTextView.hasBlueBackground(at: wordRange) {
            //                print("The word has a blue background.")
            //            } else {
            //                print("The word does not have a blue background.")
            //            }
            
            let clozeNumber = viewModel.getClozeNumber()
            
            customTextView.insertAttributedString(at: wordRange.location, with: String(clozeNumber), backgroundColor: UIColor.clozeBlueNumber, font: UIFont.systemFont(ofSize: 14, weight: .medium))
            customTextView.insertNumberLabel(at: wordRange.location, with: String(clozeNumber), backgroundColor: UIColor.clozeBlueNumber, font: UIFont.systemFont(ofSize: 14, weight: .medium))

            let highlightWordRange = NSRange(location: wordRange.location + String(clozeNumber).count, length: wordRange.length)
            let totalWordRange = NSRange(location: wordRange.location, length: wordRange.length+String(clozeNumber).count)
            
            let newCloze = NewAddCloze(number: clozeNumber, cloze: word, range: totalWordRange)
            let offset = String(clozeNumber).count
            
            viewModel.appendCloze(newCloze)
            viewModel.updateNSRange(with: newCloze, offset: offset)
            
            customTextView.highlightRanges(highlightWordRange)
        }
        
        // 檢查是否有文字被反白選中
        if let _ = customTextView.selectedTextRange {
            // 取消文字的反白選中狀態
            customTextView.selectedTextRange = nil
        }
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
