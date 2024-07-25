//
//  String+Extension.swift
//  NewWord
//
//  Created by justin on 2024/6/4.
//

import Foundation

// OBJECT REPLACEMENT CHARACTER
fileprivate let objectReplacementCharacter = "\u{FFFC}"

extension String {
    var containsChineseCharacters: Bool {
        return self.range(of: "\\p{Han}", options: .regularExpression) != nil
    }

    func startsWithObjectReplacementCharacter() -> Bool {
        if let firstCharacter = self.first, firstCharacter.unicodeScalars.first?.value == 0xFFFC {
            return true
        }
        return false
    }

    func removeObjectReplacementCharacter() -> String {
        let fffcCharacter = "\u{FFFC}" // 0xFFFC 字符
        let cleanedText = self.replacingOccurrences(of: fffcCharacter, with: "")
        return cleanedText
    }
}
