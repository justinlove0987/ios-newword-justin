//
//  Word.swift
//  NewWord
//
//  Created by justin on 2024/4/1.
//

import UIKit

struct Word {
    let text: String
    let chinese: String
}

extension Word {
    var isPunctuation: Bool {
        let punctuationRegex = try! NSRegularExpression(pattern: "^\\p{P}*$", options: [])
        return punctuationRegex.firstMatch(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count)) != nil
    }

    var size: CGSize {
        return text.size(withAttributes: [.font: UIFont.systemFont(ofSize: Preference.fontSize)])
    }

    var chineseSize: CGSize {
        return chinese.size(withAttributes: [.font: UIFont.systemFont(ofSize: Preference.fontSize)])
    }
}
