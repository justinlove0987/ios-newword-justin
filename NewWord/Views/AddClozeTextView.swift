//
//  AddClozeTextView.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/7/2.
//

import UIKit
import NaturalLanguage

class AddClozeTextView: UITextView, UITextViewDelegate {

    typealias ColoredText = WordSelectorViewControllerViewModel.ColoredText
    typealias ColoredMark = WordSelectorViewControllerViewModel.ColoredMark
    
    var highlightRangeDuringPlayback: NSRange? {
        didSet {
            setNeedsDisplay()
        }
    }

    var userSelectedColorRanges: ColoredText = .init(coloredCharacters: [:]) {
        didSet {
            setNeedsDisplay()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        setNeedsDisplay() // 重新繪製
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        self.delegate = self
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.delegate = self
    }

    override func draw(_ rect: CGRect) {
        guard self.font != nil else { return }

        let context = UIGraphicsGetCurrentContext()
        context?.saveGState()

        // 使用新的函數繪製使用者選擇的顏色區域
        drawUserSelectedColorRanges(in: context)
        drawHighlightBackground(for: highlightRangeDuringPlayback, with: UIColor.deepSlateBlue, in: context)

        context?.restoreGState()

        super.draw(rect)
    }
    
    func drawUserSelectedColorRanges(in context: CGContext?) {
        guard let font = self.font else { return }

        for (characterIndex, colorSegment) in userSelectedColorRanges.coloredCharacters {
            var positionRatio: Double = 0

            for i in 0..<colorSegment.count {
                let element = colorSegment[i]
                let isNotFirstElement = i != 0

                if isNotFirstElement {
                    positionRatio += element.heightFraction
                }

                element.contentColor.setFill()

                let range = NSRange(location: characterIndex.index, length: 1)

                layoutManager.enumerateLineFragments(forGlyphRange: range) { rect, usedRect, textContainer, glyphRange, stop in
                    let intersectionRange = NSIntersectionRange(glyphRange, range)

                    self.layoutManager.enumerateEnclosingRects(forGlyphRange: intersectionRange, withinSelectedGlyphRange: intersectionRange, in: self.textContainer) { rect, _ in
                        var adjustedRect = rect.offsetBy(dx: self.textContainerInset.left, dy: self.textContainerInset.top)
                        adjustedRect.size.height = (font.ascender - font.descender) * element.heightFraction

                        if isNotFirstElement {
                            adjustedRect.origin.y += font.lineHeight * (1 - positionRatio)
                        }

                        adjustedRect.origin.x -= 1 // 向左擴展一點
                        adjustedRect.size.width += 1 // 擴展寬度

                        context?.fill(adjustedRect)
                    }
                }
            }
        }
    }
    
    func drawHighlightBackground(for range: NSRange?, with color: UIColor, in context: CGContext?) {
        guard let range = range, let font = self.font else { return }
        
        color.setFill()

        layoutManager.enumerateLineFragments(forGlyphRange: range) { rect, usedRect, textContainer, glyphRange, stop in
            let intersectionRange = NSIntersectionRange(glyphRange, range)

            self.layoutManager.enumerateEnclosingRects(forGlyphRange: intersectionRange, withinSelectedGlyphRange: intersectionRange, in: self.textContainer) { rect, _ in
                var adjustedRect = rect.offsetBy(dx: self.textContainerInset.left, dy: self.textContainerInset.top)
                adjustedRect.size.height = font.lineHeight

                adjustedRect.origin.x -= 1 // 向左擴展一點
                adjustedRect.size.width += 1 // 擴展寬度

                // 填充背景顏色
                context?.fill(adjustedRect)
            }
        }
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        // 獲取點擊的位置所在的字符索引
        let glyphIndex = layoutManager.glyphIndex(for: point, in: textContainer, fractionOfDistanceThroughGlyph: nil)

        // 檢查字符是否在文本範圍內
        if glyphIndex < textStorage.length {
            // 檢查該字符位置是否有 NSTextAttachment
            if let attributedText = attributedText {
                let attachment = attributedText.attribute(.attachment, at: glyphIndex, effectiveRange: nil)
                if attachment is NSTextAttachment {
                    // 如果是圖片附件，阻止事件處理
                    return false
                }
            }
        }
        // 默認處理其他事件
        return super.point(inside: point, with: event)
    }

    // 禁止長按手勢
    override func addGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer is UILongPressGestureRecognizer {
            // 禁用長按手勢
            gestureRecognizer.isEnabled = false
        } else {
            super.addGestureRecognizer(gestureRecognizer)
        }
    }

    func characterIndex(at point: CGPoint) -> Int? {
        let glyphIndex = layoutManager.glyphIndex(for: point, in: textContainer)
        let characterIndex = layoutManager.characterIndexForGlyph(at: glyphIndex)
        return characterIndex
    }

    func insertNumberImageView(at location: Int, existClozes: [NewAddCloze], with textToInsert: String , scale: Double = 1.0) {
        for cloze in existClozes {
            let currentLocation = cloze.range.location

            guard currentLocation != location else {
                return
            }
        }

        // 創建自定義 UILabel
        let view = CustomNumberTagView()

        view.numberLabel.text = "\(textToInsert)"
        view.numberLabel.font = UIFont.systemFont(ofSize: view.numberLabel.font.pointSize * scale)

        view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: self.font!.lineHeight*scale)
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
    }

    func renewTagImages(_ coloredMarks: [ColoredMark]) {
        for coloredMark in coloredMarks {
            let tagView = CustomTagView(coloredMark: coloredMark, lineHeight: self.font!.lineHeight)

            tagView.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                tagView.heightAnchor.constraint(equalToConstant: self.font!.lineHeight)
            ])

            tagView.layoutIfNeeded()
            tagView.cornerRadiusCallback?()

            let image = tagView.asImage()

            let attachment = NSTextAttachment()
            attachment.image = image

            attachment.bounds = CGRect(x: 0, y: self.font?.descender ?? 0, width: image.size.width, height: image.size.height)

            let attachmentString = NSAttributedString(attachment: attachment)
            let replaceRange = NSRange(location: coloredMark.characterIndex, length: 1)

            textStorage.replaceCharacters(in: replaceRange, with: attachmentString)

            setNeedsLayout()
        }
    }

    func removeNumberImageView(at location: Int) {
        textStorage.deleteCharacters(in: NSRange(location: location, length: 1))
    }

    func sentenceRangeContainingCharacter(at characterIndex: Int) -> NSRange? {
        guard let text = self.text else { return nil }

        let tokenizer = NLTokenizer(unit: .sentence)
        tokenizer.string = text
        let stringIndex = text.index(text.startIndex, offsetBy: characterIndex)
        let sentenceRange = tokenizer.tokenRange(at: stringIndex)

        var nsRange = NSRange(sentenceRange, in: text)

        let sentence = Array(text[sentenceRange])
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

    func isTextSelected() -> Bool {
        return self.selectedRange.length > 0
    }

    static func createTextView(_ text: String) -> AddClozeTextView {
        let attributedString = NSMutableAttributedString(string: text)

        let textStorage = NSTextStorage(attributedString: attributedString)
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: .zero)

        textStorage.addLayoutManager(layoutManager)
        layoutManager.addTextContainer(textContainer)

        let textView = AddClozeTextView(frame: .zero, textContainer: textContainer)

        textView.backgroundColor = .clear
        textView.isEditable = false
        textView.setProperties()

        return textView
    }

    func setProperties() {
        guard let text = self.text else { return }
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = UserDefaultsManager.shared.preferredLineSpacing
        
        // 設置字體和段落樣式
        let attributes: [NSAttributedString.Key: Any] = [
            .paragraphStyle: paragraphStyle,
            .font: UIFont.systemFont(ofSize: UserDefaultsManager.shared.preferredFontSize, weight: .medium),
            .foregroundColor: UIColor.title
        ]
        
        font = UIFont.systemFont(ofSize: UserDefaultsManager.shared.preferredFontSize, weight: .medium)
        textColor = UIColor.title
        textStorage.addAttributes(attributes, range: NSRange(location: 0, length: text.count))
        
        // 計算文字大小
        let size = CGSize(width: self.frame.width, height: CGFloat.greatestFiniteMagnitude)
        let boundingRect = (text as NSString).boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
        
        // 設置contentSize
        
        if boundingRect.height < self.frame.height + 30 {
            self.contentSize =  CGSize(width: self.frame.width, height: self.frame.height + 30)
        }
    }
    
    func updateCurrentHighlightWordRange(comparedRange: NSRange, adjustmentOffset: Int) {
        guard let highlightRangeDuringPlayback else { return }
        
        let isLocationGreater = highlightRangeDuringPlayback.location >= comparedRange.location
        let newLocation = highlightRangeDuringPlayback.location + adjustmentOffset
        
        self.highlightRangeDuringPlayback = NSRange(location: newLocation, length: highlightRangeDuringPlayback.length)
        
        self.setNeedsDisplay()
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


