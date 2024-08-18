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

        if isLocationGreater {
            let newLocation = highlightRangeDuringPlayback.location + adjustmentOffset

            self.highlightRangeDuringPlayback = NSRange(location: newLocation, length: highlightRangeDuringPlayback.length)
            self.setNeedsDisplay()
        }
    }

    func addDottedUnderline(in range: NSRange) {
        textStorage.addAttribute(.underlineStyle, value: NSUnderlineStyle.thick.rawValue, range: range)
    }

    private var animationLayers: [CAShapeLayer] = []
    private var animationLayer: CAShapeLayer?
    private var fakeLayer: CAShapeLayer?
    private var gradientLayer: CAGradientLayer?


    var underlineColor: UIColor = .blue
    var underlineHeight: CGFloat = 4
    var underlineOffset: CGFloat = 0.0
    var dashPattern: [NSNumber] = [4, 4]

    func addDashedUnderline(in range: NSRange) {
        guard self.font != nil else { return }

        let layoutManager = self.layoutManager
        let textContainer = self.textContainer

        layoutManager.ensureLayout(for: textContainer)

        let glyphRange = layoutManager.glyphRange(forCharacterRange: range, actualCharacterRange: nil)

        layoutManager.enumerateLineFragments(forGlyphRange: glyphRange) { rect, usedRect, _, glyphRange, _ in

            // 計算每行的字符範圍
            let characterRange = layoutManager.characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil)
            let lineRange = NSIntersectionRange(characterRange, range)

            // 如果這一行確實在 NSRange 的範圍內
            guard lineRange.length > 0 else { return }

            // 確保虛線只繪製在有效範圍內
            let startX = layoutManager.boundingRect(forGlyphRange: layoutManager.glyphRange(forCharacterRange: NSRange(location: lineRange.location, length: 1), actualCharacterRange: nil), in: textContainer).minX
            let endX = layoutManager.boundingRect(forGlyphRange: layoutManager.glyphRange(forCharacterRange: NSRange(location: NSMaxRange(lineRange) - 1, length: 1), actualCharacterRange: nil), in: textContainer).maxX

            let underlineY = rect.origin.y + rect.size.height + self.underlineOffset + self.underlineHeight / 2

            let path = UIBezierPath()
            path.move(to: CGPoint(x: startX, y: underlineY))
            path.addLine(to: CGPoint(x: endX, y: underlineY))

            let shapeLayer = CAShapeLayer()
            shapeLayer.path = path.cgPath
            shapeLayer.strokeColor = self.underlineColor.cgColor
            shapeLayer.lineWidth = self.underlineHeight
            shapeLayer.lineDashPattern = self.dashPattern

            self.layer.addSublayer(shapeLayer)
            self.animationLayer = shapeLayer

        }
    }

    func addDashedUnderlineWord(in range: NSRange) {
        guard self.font != nil else { return }

        // 獲取textStorage的layoutManager
        let layoutManager = self.layoutManager
        let textContainer = self.textContainer

        layoutManager.ensureLayout(for: textContainer)

        // 獲取範圍內的字符框架
        let glyphRange = layoutManager.glyphRange(forCharacterRange: range, actualCharacterRange: nil)

        // 計算範圍內的字元框架
        layoutManager.enumerateEnclosingRects(forGlyphRange: glyphRange, withinSelectedGlyphRange: glyphRange, in: textContainer) { rect, stop in

            let underlineY = rect.origin.y + rect.size.height + self.underlineOffset

            // 創建 UIView 作為虛線下劃線
            let underlineView = UIView(frame: CGRect(x: rect.origin.x, y: underlineY, width: rect.size.width, height: self.underlineHeight))

            // 創建 CAShapeLayer 用來繪製虛線
            let shapeLayer = CAShapeLayer()
            let path = UIBezierPath()
            path.move(to: CGPoint(x: 0, y: self.underlineHeight / 2))
            path.addLine(to: CGPoint(x: rect.size.width, y: self.underlineHeight / 2))

            shapeLayer.path = path.cgPath
            shapeLayer.strokeColor = UIColor.red.cgColor // 虛線顏色
            shapeLayer.lineWidth = self.underlineHeight
            shapeLayer.lineDashPattern = self.dashPattern

            underlineView.layer.addSublayer(shapeLayer)

            self.gradientSet.append([self.gradientOne, self.gradientTwo])
            self.gradientSet.append([self.gradientTwo, self.gradientOne])
//            self.gradientSet.append([self.gradientThree, self.gradientOne])

            // 創建 CAGradientLayer 用來添加漸層顏色
            let gradientLayer = CAGradientLayer()

            gradientLayer.frame = underlineView.bounds
            gradientLayer.colors = self.gradientSet[self.currentGradient]
//            gradientLayer.colors = [UIColor.clear.cgColor, UIColor.red.cgColor, UIColor.clear.cgColor]
            gradientLayer.startPoint = CGPoint(x:0, y:0.5)
            gradientLayer.endPoint = CGPoint(x:1, y:0.5)
            gradientLayer.drawsAsynchronously = true
            gradientLayer.mask = shapeLayer

            underlineView.layer.addSublayer(gradientLayer)
            self.gradientLayer = gradientLayer

            // 把 UIView 添加到當前視圖中
            self.addSubview(underlineView)

            // 設置 UIView 的層級，以確保它在文本上方
            self.bringSubviewToFront(underlineView)

            // 創建 CAGradientLayer 用來添加漸層顏色
            let movingGradientLayer = CAGradientLayer()

            movingGradientLayer.frame = CGRect(x: 0, y: 0, width: underlineView.bounds.width / 2, height: underlineView.bounds.height)
            movingGradientLayer.colors = [UIColor.clear.cgColor, UIColor.red.cgColor, UIColor.clear.cgColor]
            movingGradientLayer.startPoint = CGPoint(x:0, y:0.5)
            movingGradientLayer.endPoint = CGPoint(x:1, y:0.5)
            movingGradientLayer.drawsAsynchronously = true
//            movingGradientLayer.mask = shapeLayer
//            underlineView.layer.addSublayer(movingGradientLayer)

            self.animateGradient(to: gradientLayer)
//            self.animateGradient(layer: movingGradientLayer, viewWidth: rect.size.width)
        }
    }

    private func addTransitionAnimation(to layer: CAGradientLayer) {
        let group = makeAnimationGroup()
        group.beginTime = 0.0
        print("Animation Group: \(group)")
        layer.add(group, forKey: "backgroundColor")
    }

    private func tryAnimation(to layer: CAShapeLayer) {
        let group = testAnimationGroup()
        group.beginTime = 0.0
        group.repeatCount = .infinity
        group.isRemovedOnCompletion = false
        print("Animation Group: \(group)")
        layer.add(group, forKey: "backgroundColor")
    }

    let gradient = CAGradientLayer()
    var gradientSet = [[CGColor]]()
    var currentGradient: Int = 0
    
//    let gradientOne = UIColor(red: 239 / 255.0, green: 241 / 255.0, blue: 241 / 255.0, alpha: 1).cgColor
//    let gradientTwo = UIColor(red: 201 / 255.0, green: 201 / 255.0, blue: 201 / 255.0, alpha: 1).cgColor
//    let gradientThree = UIColor.green.cgColor
    let gradientOne = UIColor(red: 48/255, green: 62/255, blue: 103/255, alpha: 1).cgColor
    let gradientTwo = UIColor(red: 244/255, green: 88/255, blue: 53/255, alpha: 1).cgColor
//    let gradientThree = UIColor(red: 196/255, green: 70/255, blue: 107/255, alpha: 1).cgColor

    func animateGradient(to layer: CAGradientLayer) {
        let gradientChangeAnimation = CABasicAnimation(keyPath: "colors")

        gradientChangeAnimation.fillMode = .forwards
        gradientChangeAnimation.delegate = self
        gradientChangeAnimation.duration = 1

        gradientChangeAnimation.fromValue = gradientSet[currentGradient]

        if currentGradient < gradientSet.count - 1 {
            currentGradient += 1
        } else {
            currentGradient = 0
        }

        gradientChangeAnimation.toValue = gradientSet[currentGradient]


        gradientChangeAnimation.isRemovedOnCompletion = false

        layer.add(gradientChangeAnimation, forKey: "colorChange")
    }

    func animateGradient(layer: CAGradientLayer, viewWidth: CGFloat) {
        let animation = CABasicAnimation(keyPath: "position.x")
        animation.fromValue = 0
        animation.toValue = viewWidth
        animation.duration = 2.0
        animation.repeatCount = .infinity

        layer.add(animation, forKey: "animateGradient")
    }

    func moveFirstElementToLast(in layers: inout [CAShapeLayer]) {
        // 確保陣列不為空
        guard !layers.isEmpty else { return }

        // 移動第一個元素到最後一個位置
        let firstElement = layers.removeFirst()
        layers.append(firstElement)
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

// MARK: - SkeletonLoadable

extension AddClozeTextView: SkeletonLoadable {}

// MARK: - CAAnimationDelegate

extension AddClozeTextView: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        guard let gradientLayer else { return }

        if flag {
            animateGradient(to: gradientLayer)
        }
    }
}
