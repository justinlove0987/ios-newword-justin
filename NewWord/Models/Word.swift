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
    let chinese: String
}

extension Word {
    var isPunctuation: Bool {
        let punctuationRegex = try! NSRegularExpression(pattern: "^\\p{P}*$", options: [])
        return punctuationRegex.firstMatch(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count)) != nil
    }

    var bound: CGSize {
        return text.size(withAttributes: [.font: UIFont.systemFont(ofSize: Preference.fontSize)])
    }

    var chineseBound: CGSize {
        return text.size(withAttributes: [.font: UIFont.systemFont(ofSize: Preference.fontSize)])
    }
}
