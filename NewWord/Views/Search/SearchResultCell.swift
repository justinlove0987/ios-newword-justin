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
    @IBOutlet weak var innerView: UIView!
    
    func configureUI(itemIdentifier: SearchResultViewController.Item) {
        innerView.addDefaultBorder()
        textView.isEditable = false
        textView.isScrollEnabled = true
        
        if case let  .highlightContext(hightlightContext) = itemIdentifier {
            let text = hightlightContext.text
            let location = hightlightContext.highlightRange.location
            let length = hightlightContext.highlightRange.length
            let range = NSRange(location: location, length: length)
            
            let attributedString = textView.highlightText(text, in: range)
            
            textView.attributedText = attributedString
            textView.scrollToRange(range)
        }
    }
}
