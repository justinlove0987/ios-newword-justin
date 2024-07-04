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

    var highlightedRanges: [NSRange] = []

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

        // 繪製所有高亮範圍
        for highlightedRange in highlightedRanges {
            layoutManager.enumerateLineFragments(forGlyphRange: range) { (rect, usedRect, textContainer, glyphRange, stop) in
                let characterRange = self.layoutManager.characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil)
                if NSIntersectionRange(characterRange, highlightedRange).length > 0 {
                    let intersectedRange = NSIntersectionRange(characterRange, highlightedRange)
                    let glyphRange = self.layoutManager.glyphRange(forCharacterRange: intersectedRange, actualCharacterRange: nil)

                    let boundingRect = self.layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
                    let adjustedRect = boundingRect.offsetBy(dx: self.textContainerInset.left, dy: self.textContainerInset.top)

                    let path = UIBezierPath(roundedRect: adjustedRect, byRoundingCorners: [.topLeft], cornerRadii: CGSize(width: 5, height: 5))
                    UIColor.blue.setFill()
                    path.fill()
                }
            }
        }

        // 遍歷文本中的所有字符範圍
//        layoutManager.enumerateLineFragments(forGlyphRange: range) { (rect, usedRect, textContainer, glyphRange, stop) in
//            // 檢查每個字符是否在我們需要繪製背景色的範圍內
//            let characterRange = self.layoutManager.characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil)
//
//            if NSIntersectionRange(characterRange, highlightedRange).length > 0 {
//                let intersectedRange = NSIntersectionRange(characterRange, highlightedRange)
//                let glyphRange = self.layoutManager.glyphRange(forCharacterRange: intersectedRange, actualCharacterRange: nil)
//
//                // 獲取範圍內的矩形區域
//
//                let boundingRect = self.layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
//
//                // 調整 boundingRect 的位置
//                let adjustedRect = boundingRect.offsetBy(dx: self.textContainerInset.left, dy: self.textContainerInset.top)
//
//                // 設置背景顏色和圓角
//                let path = UIBezierPath(roundedRect: adjustedRect, byRoundingCorners: [.topLeft], cornerRadii: CGSize(width: 5, height: 5))
//                UIColor.blue.setFill()
//                path.fill()
//            }
//        }

        // 恢復繪圖狀態
        context.restoreGState()

        super.draw(rect)
    }

    func characterIndex(at point: CGPoint) -> Int? {
        let glyphIndex = layoutManager.glyphIndex(for: point, in: textContainer)
        let characterIndex = layoutManager.characterIndexForGlyph(at: glyphIndex)
        return characterIndex
    }

    func highlightRanges(_ range: NSRange) {
        highlightedRange = range
        highlightedRanges.append(range)
//        textStorage.addAttribute(.backgroundColor, value: UIColor.clozeBlueText, range: range)
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

    func insertNumberLabel(at location: Int, with textToInsert: String, backgroundColor: UIColor, font: UIFont) {

        let attributedString = NSMutableAttributedString(attributedString: self.attributedText)

        // 創建自定義 UILabel
        let label = UILabel()
        label.text = textToInsert
        label.font = self.font // 將UILabel的字體設置為與UITextView的字體一致
        label.sizeToFit()

        // 將 UILabel 渲染為圖像
        let labelImage = imageFromLabel(label)

        // 創建帶有圖像的文本附件
        let attachment = NSTextAttachment()
        attachment.image = labelImage

        // 設置附件的邊界以定義其大小和位置
        attachment.bounds = CGRect(x: 0, y: self.font?.descender ?? 0, width: labelImage.size.width, height: labelImage.size.height)

        // 創建帶有附件的帶屬性字符串
        let attachmentString = NSAttributedString(attachment: attachment)

        // 在主屬性字符串的特定位置插入附件字符串
        attributedString.insert(attachmentString, at: location) // 例如：在索引 6（第7個字符）插入

        // 設置最終的帶屬性字符串到文本視圖
        self.attributedText = attributedString
    }

    func imageFromLabel(_ label: UILabel) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(label.bounds.size, false, 0.0)
        label.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image ?? UIImage()
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
