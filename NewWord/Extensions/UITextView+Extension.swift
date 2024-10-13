//
//  UITextView+Extension.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/8/20.
//

import UIKit
import NaturalLanguage

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
    
    func highlightText(_ text: String,
                       in range: NSRange,
                       fontSize: CGFloat = 20,
                       highlightColor: UIColor = .yellow) -> NSAttributedString {
        
        // 創建一個 NSMutableAttributedString
        let attributedString = NSMutableAttributedString(string: text)

        // 設置整體屬性
        let overallAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: fontSize),
            .foregroundColor: UIColor.title
        ]

        attributedString.addAttributes(overallAttributes, range: NSRange(location: 0, length: attributedString.length))

        // 設置高亮屬性
        let highlightAttributes: [NSAttributedString.Key: Any] = [
            .backgroundColor: UIColor.clozeBlueText
        ]

        // 對指定範圍應用高亮屬性
        attributedString.addAttributes(highlightAttributes, range: range)

        return attributedString
    }
    
    func applyTextColor(_ color: UIColor, to range: NSRange) {
        guard let text = self.text, range.location + range.length <= text.count else {
            print("Range out of bounds")
            return
        }
        
        let attributedString = NSMutableAttributedString(attributedString: self.attributedText)
        attributedString.addAttribute(.foregroundColor, value: color, range: range)
        self.attributedText = attributedString
    }
    
    func scrollToRange(_ range: NSRange) {
        guard let text = self.text, range.location + range.length <= text.count else {
            print("Range out of bounds")
            return
        }

        // 使用 DispatchQueue.main.async 確保文本渲染完成
        DispatchQueue.main.async {
            // 獲取範圍起始位置的 UITextPosition
            if let startPosition = self.position(from: self.beginningOfDocument, offset: range.location) {
                var caretRect = self.caretRect(for: startPosition)

                // 這裡可以進行額外的邊距調整以確保文本完全顯示
                let inset: CGFloat = 60
                caretRect = caretRect.inset(by: UIEdgeInsets(top: -inset, left: -inset, bottom: -inset, right: -inset))

                // 滾動到目標範圍
                self.scrollRectToVisible(caretRect, animated: false)
            } else {
                print("Invalid position")
            }
        }
    }
}
