//
//  CustomTextView.swift
//  NewWord
//
//  Created by justin on 2024/6/26.
//

import UIKit

class CustomTextView: UITextView {
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
    
    func configureText() {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 18, weight: .medium),
            .foregroundColor: UIColor.white
        ]

        let attributedString = NSMutableAttributedString(string: self.text, attributes: attributes)
        
        self.isEditable = false
        self.isScrollEnabled = true
        self.backgroundColor = .clear
        self.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        self.attributedText = attributedString
    }
    
    func highlightRange(_ range: NSRange) {
        self.textStorage.addAttributes([.foregroundColor: UIColor.blue], range: range)
    }
}
