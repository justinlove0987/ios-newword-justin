//
//  Word.swift
//  NewWord
//
//  Created by justin on 2024/4/1.
//

import UIKit

struct Word {
    let text: String
    var isReview: Bool
}

extension Word {
    var isPunctuation: Bool {
        let punctuationRegex = try! NSRegularExpression(pattern: "^\\p{P}*$", options: [])
        return punctuationRegex.firstMatch(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count)) != nil
    }

    var bound: CGRect {
        return (text as NSString).boundingRect(with: CGSize(width: CGFloat.infinity, height: CGFloat.infinity),
                                               attributes: [.font : UIFont.systemFont(ofSize: 20)],
                                               context: nil)
    }
}
