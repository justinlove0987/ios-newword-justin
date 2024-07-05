//
//  AddClozeTextView.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/7/2.
//

import UIKit
import NaturalLanguage

class AddClozeTextView: UITextView {

    var highlightedRanges: [NSRange] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func characterIndex(at point: CGPoint) -> Int? {
        let glyphIndex = layoutManager.glyphIndex(for: point, in: textContainer)
        let characterIndex = layoutManager.characterIndexForGlyph(at: glyphIndex)
        return characterIndex
    }

    func highlightClozeWord(_ range: NSRange) {
        textStorage.addAttribute(.backgroundColor, value: UIColor.clozeBlueText, range: range)
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
            view.heightAnchor.constraint(equalToConstant: self.font!.lineHeight + 1)
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


extension UIView {

    func asImage() -> UIImage {
        if #available(iOS 10.0, *) {
            let renderer = UIGraphicsImageRenderer(bounds: bounds)
            return renderer.image { rendererContext in
                layer.render(in: rendererContext.cgContext)
            }
        } else {
            UIGraphicsBeginImageContext(self.frame.size)
            self.layer.render(in:UIGraphicsGetCurrentContext()!)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return UIImage(cgImage: image!.cgImage!)
        }
    }
}

class CustomTextAttachment: NSTextAttachment {
    var attachedView: UIView?
}
