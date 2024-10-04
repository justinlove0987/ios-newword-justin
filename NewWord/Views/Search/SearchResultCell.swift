//
//  SearchResultCell.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/10/4.
//

import UIKit

class SearchResultCell: UICollectionViewCell {
    
    static let reuseIdentifier = String(describing: SearchResultCell.self)
    
    
    @IBOutlet weak var textView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureUI(itemIdentifier: SearchResultViewController.Item) {
//        itemIdentifier.practiceContext.
        
        
//        let range = NSRange(location: Int(cloze.location), length: Int(cloze.length))
//
//        let attributedString = highlightText(context, in: range)
//
//        textView.attributedText = attributedString
//
//
//        scrollToRange(range, in: textView)
    }
    
    func highlightText(_ text: String, in range: NSRange, highlightColor: UIColor = .yellow) -> NSAttributedString {
        // 創建一個 NSMutableAttributedString
        let attributedString = NSMutableAttributedString(string: text)

        // 設置整體屬性
        let overallAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 17),
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


    func scrollToRange(_ range: NSRange, in textView: UITextView) {
        guard let text = textView.text, range.location + range.length <= text.count else {
            print("Range out of bounds")
            return
        }

        // 使用 DispatchQueue.main.async 確保文本渲染完成
        DispatchQueue.main.async {
            // 獲取範圍起始位置的 UITextPosition
            if let startPosition = textView.position(from: textView.beginningOfDocument, offset: range.location) {
                var caretRect = textView.caretRect(for: startPosition)

                // 這裡可以進行額外的邊距調整以確保文本完全顯示
                let inset: CGFloat = 60
                caretRect = caretRect.inset(by: UIEdgeInsets(top: -inset, left: -inset, bottom: -inset, right: -inset))

                // 滾動到目標範圍
                textView.scrollRectToVisible(caretRect, animated: false)
            } else {
                print("Invalid position")
            }
        }
    }
}
