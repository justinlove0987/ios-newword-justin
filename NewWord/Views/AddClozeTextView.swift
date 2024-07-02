//
//  AddClozeTextView.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/7/2.
//

import UIKit
import NaturalLanguage

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
    
    func insertAttributedString(at location: Int, with textToInsert: String, backgroundColor: UIColor, font: UIFont) {
        
        let mutableAttributedString = NSMutableAttributedString(attributedString: self.attributedText)
        let attributedStringToInsert = NSMutableAttributedString(string: textToInsert,
                                                                 attributes: [
                                                                    .backgroundColor: backgroundColor,
                                                                    .font: font
                                                                 ])
        
        mutableAttributedString.insert(attributedStringToInsert, at: location)
        self.attributedText = mutableAttributedString
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

extension NSAttributedString.Key {
    static let increasedSpacing = NSAttributedString.Key("IncreasedSpacingAttribute")
}

extension NSMutableAttributedString {
    func addIncreasedSpacingAttribute(range: NSRange) {
        self.addAttribute(.increasedSpacing, value: true, range: range)
    }
}
