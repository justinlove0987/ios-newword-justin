//
//  AddClozeTextView.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/7/2.
//

import UIKit
import NaturalLanguage

class AddClozeTextView: UITextView {

    var highlightedRanges: [NSRange] = [] {
        didSet {
            setNeedsDisplay()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        setNeedsDisplay() // 重新繪製
    }

    func characterIndex(at point: CGPoint) -> Int? {
        let glyphIndex = layoutManager.glyphIndex(for: point, in: textContainer)
        let characterIndex = layoutManager.characterIndexForGlyph(at: glyphIndex)
        return characterIndex
    }

    func deHightlightCloze(_ range: NSRange) {
        textStorage.removeAttribute(.backgroundColor, range: range)
    }

    func hasBlueBackground(at range: NSRange) -> Bool {
        let attribute = textStorage.attribute(.backgroundColor, at: range.location, effectiveRange: nil) as? UIColor
        return attribute == UIColor.blue
    }

    func insertNumberImageView(at location: Int, with textToInsert: String) {
        // 創建自定義 UILabel
        let view = CustomNumberTagView()
        view.numberLabel.text = "\(textToInsert)"
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: self.font!.lineHeight)
        ])
        
        view.layoutIfNeeded()
        
        let path =  UIBezierPath(roundedRect: view.bounds, byRoundingCorners: .topLeft, cornerRadii: CGSize(width: 3, height: 3))
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath

        view.layer.mask = maskLayer
        
        // 將 UILabel 渲染為圖像
        let labelImage = view.asImage()

        // 創建帶有圖像的文本附件
        let attachment = NSTextAttachment()
        attachment.image = labelImage

        // 設置附件的邊界以定義其大小和位置
        attachment.bounds = CGRect(x: 0, y: self.font?.descender ?? 0, width: labelImage.size.width, height: labelImage.size.height)

        // 創建帶有附件的帶屬性字符串
        let attachmentString = NSAttributedString(attachment: attachment)
        
        textStorage.insert(attachmentString, at: location)

        setNeedsLayout()
        layoutIfNeeded()
    }
    
    func removeNumberImageView(at location: Int) {
        textStorage.deleteCharacters(in: NSRange(location: location, length: 1))
    }

    func imageFromLabel(_ label: UILabel) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(label.bounds.size, false, 0.0)
        label.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let returnImage = image ?? UIImage()
        
        return returnImage
    }

    func increaseLineSpacing(_ lineSpacing: CGFloat) {
        guard let text = self.text else { return }

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing

        textStorage.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: text.count))
    }

    override func draw(_ rect: CGRect) {
        guard let font = self.font else { return }

        let context = UIGraphicsGetCurrentContext()
        context?.saveGState()

        UIColor.clozeBlueText.setFill()
        
        for range in highlightedRanges {
            layoutManager.enumerateLineFragments(forGlyphRange: range) { rect, usedRect, textContainer, glyphRange, stop in
                // Ensure we only draw the part of the line within the specified range
                let intersectionRange = NSIntersectionRange(glyphRange, range)
                self.layoutManager.enumerateEnclosingRects(forGlyphRange: intersectionRange, withinSelectedGlyphRange: intersectionRange, in: self.textContainer) { rect, _ in
                    var adjustedRect = rect.offsetBy(dx: self.textContainerInset.left, dy: self.textContainerInset.top)

                    adjustedRect.size.height = font.ascender - font.descender
                    adjustedRect.origin.y += (font.lineHeight - adjustedRect.size.height) / 2
                    context?.fill(adjustedRect)
                }
            }
        }

        context?.restoreGState()

        super.draw(rect)
    }
    
    func sentenceRangeContainingCharacter(at characterIndex: Int) -> NSRange? {
        guard let text = self.text else { return nil }

        let tokenizer = NLTokenizer(unit: .sentence)
        tokenizer.string = text
        let stringIndex = text.index(text.startIndex, offsetBy: characterIndex)
        let sentenceRange = tokenizer.tokenRange(at: stringIndex)
        
        var nsRange = NSRange(sentenceRange, in: text)

        var sentence = Array(text[sentenceRange])
        var i = sentence.count - 1
        var j = 0

        while i > 0 {
            let lastWord = sentence[i]

            if lastWord.isWhitespace || lastWord.isNewline {
                i -= 1
                nsRange.length -= 1
            } else {
                break
            }
        }


        while j < sentence.count {
            let firstWord = String(sentence[j])

            // 檢查第一個字是不是物件替代字符
            if firstWord.startsWithObjectReplacementCharacter() {
                j += 1
                nsRange.location += 1
                nsRange.length -= 1
            } else {
                break
            }
        }

        return nsRange
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
