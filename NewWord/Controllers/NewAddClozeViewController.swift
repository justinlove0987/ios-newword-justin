//
//  NewAddClozeViewController.swift
//  NewWord
//
//  Created by justin on 2024/6/30.
//

import UIKit
import NaturalLanguage

class NewAddClozeViewController: UIViewController, StoryboardGenerated {
    
    struct NewAddCloze {
        let number: Int
        let cloze: String
        let range: NSRange
    }
    
    static var storyboardName: String = K.Storyboard.main
    
    @IBOutlet weak var textView: UITextView!
    private var customTextView: AddClozeTextView!
    
    private var clozeNumbers: Set<Int> = .init()
    
    private var clozes: [NewAddCloze] = []
    
    // MARK: - Lifecycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextView()
        setupCumstomTextView()
    }
    
    // MARK: - Helpers
    
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
        customTextView.isEditable = false
        customTextView.isScrollEnabled = true
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
        
        saveCloze()
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
            print("Tapped word: \(word)")
            
            // 判斷點擊的單字是否有藍色背景
            //            if customTextView.hasBlueBackground(at: wordRange) {
            //                print("The word has a blue background.")
            //            } else {
            //                print("The word does not have a blue background.")
            //            }
            
            let clozeNumber = getClozeNumbre()
            
            let mutableAttributedString = NSMutableAttributedString(attributedString: customTextView.attributedText)
            let yellowOne = NSMutableAttributedString(string: String(clozeNumber),
                                                      attributes: [
                                                        .backgroundColor: UIColor.clozeBlueNumber,
                                                        .font: UIFont.systemFont(ofSize: 14, weight: .medium),
                                                        // .kern: 2, // 調整數字1與後面字符的間距
                                                      ])
            
            mutableAttributedString.insert(yellowOne, at: wordRange.location)
            customTextView.attributedText = mutableAttributedString
            
            // 更新highlight範圍包括"1"
            let updatedWordRange = NSRange(location: wordRange.location + String(clozeNumber).count, length: wordRange.length)
            
            
            clozes.append(NewAddCloze(number: clozeNumber, cloze: word, range: updatedWordRange))
            
            customTextView.highlightRange(updatedWordRange)
        }
        
        // 檢查是否有文字被反白選中
        if let _ = customTextView.selectedTextRange {
            // 取消文字的反白選中狀態
            customTextView.selectedTextRange = nil
        }
    }
    
    func convertToContext(_ text: String, _ cloze: NewAddCloze) -> String {
        let attributedText = NSMutableAttributedString(string: text)
        let frontCharacter = NSAttributedString(string: "{{C")
        let middleColon = NSAttributedString(string: "\(cloze.number):")
        let backCharacter = NSAttributedString(string: "}}")

        let backIndex = cloze.range.location + cloze.range.length-1
        let frontIndex = cloze.range.location-1
        let middleColonIndex = frontIndex + String(cloze.number).count-1
        
        attributedText.insert(backCharacter, at: backIndex)
        attributedText.insert(middleColon, at: middleColonIndex)
        attributedText.insert(frontCharacter, at: frontIndex)
        
        return attributedText.string
    }
    
    func getClozeNumbre() -> Int {
        if clozeNumbers.isEmpty {
            clozeNumbers.insert(1)
            return 1
        }
        
        var maxClozeNumber = clozeNumbers.max()
        
        maxClozeNumber! += 1
        
        if clozeNumbers.contains(maxClozeNumber!) {
            while clozeNumbers.contains(maxClozeNumber! + 1) {
                maxClozeNumber! += 1
            }
        }
        
        clozeNumbers.insert(maxClozeNumber!)
        
        return maxClozeNumber!
    }
    
    private func saveCloze() {
        guard var text = textView.text else { return }

        
        let firstDeck = CoreDataManager.shared.getDecks().first!
        
        for cloze in clozes {
            let number = cloze.number
            text = convertToContext(text, cloze)
        }
        
        let context = CoreDataManager.shared.createContext(text)
        
        for cloze in clozes {
            let cloze = CoreDataManager.shared.createCloze(number: cloze.number, hint: "", clozeWord: cloze.cloze)
            cloze.context = context
            cloze.contextId = context.id
            
            let noteType = CoreDataManager.shared.createNoteNoteType(rawValue: 1)
            noteType.cloze = cloze
            
            let note = CoreDataManager.shared.createNote(noteType: noteType)
            
            CoreDataManager.shared.addCard(to: firstDeck, with: note)
        }

        CoreDataManager.shared.save()

        navigationController?.popViewController(animated: true)
    }
}

extension UITextView {
    func wordRange(at index: Int) -> NSRange? {
        guard let text = self.text else { return nil }
        let textNSString = text as NSString
        let range = textNSString.rangeOfComposedCharacterSequence(at: index)
        guard let swiftRange = Range(range, in: text) else { return nil }
        let tokenizer = NLTokenizer(unit: .word)
        tokenizer.string = text
        let wordRange = tokenizer.tokenRange(for: swiftRange)
        return NSRange(wordRange, in: text)
    }
}

class AddClozeTextView: UITextView {
    var highlightedRange: NSRange?

    override func layoutSubviews() {
        super.layoutSubviews()
        setNeedsDisplay() // 重新繪製
    }

    override func draw(_ rect: CGRect) {
        guard let textStorage = layoutManager.textStorage else { return }
        guard let highlightedRange = highlightedRange else { return }

        let range = NSRange(location: 0, length: textStorage.length)

        // 獲取上下文
        guard let context = UIGraphicsGetCurrentContext() else { return }

        // 保存當前繪圖狀態
        context.saveGState()

        // 遍歷文本中的所有字符範圍
        layoutManager.enumerateLineFragments(forGlyphRange: range) { (rect, usedRect, textContainer, glyphRange, stop) in
            // 檢查每個字符是否在我們需要繪製背景色的範圍內
            let characterRange = self.layoutManager.characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil)
            if NSIntersectionRange(characterRange, highlightedRange).length > 0 {
                let intersectedRange = NSIntersectionRange(characterRange, highlightedRange)
                let glyphRange = self.layoutManager.glyphRange(forCharacterRange: intersectedRange, actualCharacterRange: nil)

                // 獲取範圍內的矩形區域

                let boundingRect = self.layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)

                // 調整 boundingRect 的位置
                let adjustedRect = boundingRect.offsetBy(dx: self.textContainerInset.left, dy: self.textContainerInset.top)

                // 設置背景顏色和圓角
                let path = UIBezierPath(roundedRect: adjustedRect.insetBy(dx: 0, dy: 0), cornerRadius: 5)
                UIColor.blue.setFill()
                path.fill()


            }
        }

        // 恢復繪圖狀態
        context.restoreGState()

        super.draw(rect)
    }

    func characterIndex(at point: CGPoint) -> Int? {
        let glyphIndex = layoutManager.glyphIndex(for: point, in: textContainer)
        let characterIndex = layoutManager.characterIndexForGlyph(at: glyphIndex)
        return characterIndex
    }

    func highlightRange(_ range: NSRange) {
        highlightedRange = range
        textStorage.addAttribute(.backgroundColor, value: UIColor.clozeBlueText, range: range)
        setNeedsDisplay()
    }

    func hasBlueBackground(at range: NSRange) -> Bool {
        let attribute = textStorage.attribute(.backgroundColor, at: range.location, effectiveRange: nil) as? UIColor
        return attribute == UIColor.blue
    }
}

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
