//
//  NewAddClozeViewController.swift
//  NewWord
//
//  Created by justin on 2024/6/30.
//

import UIKit
import NaturalLanguage

class NewAddClozeViewController: UIViewController, StoryboardGenerated {

    static var storyboardName: String = K.Storyboard.main

    @IBOutlet weak var textView: UITextView!
    private var customTextView: AddClozeTextView!

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
    }

    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        guard let customTextView = gesture.view as? AddClozeTextView else { return }
        var location = gesture.location(in: customTextView)

        location.x -= customTextView.textContainerInset.left
        location.y -= customTextView.textContainerInset.top

        if let characterIndex = customTextView.characterIndex(at: location),
           let wordRange = customTextView.wordRange(at: characterIndex) {
            customTextView.highlightRange(wordRange)
        }

        // 檢查是否有文字被反白選中
        if let selectedRange = customTextView.selectedTextRange {
            // 取消文字的反白選中狀態
            customTextView.selectedTextRange = nil
        }
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
                let path = UIBezierPath(roundedRect: adjustedRect.insetBy(dx: -2, dy: -2), cornerRadius: 5)
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
        textStorage.addAttribute(.backgroundColor, value: UIColor.blue, range: range)
        setNeedsDisplay()
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

            print("Selected text: \(selectedText)")
            print("Selected range: \(selectedRange)")
        }
    }
}
