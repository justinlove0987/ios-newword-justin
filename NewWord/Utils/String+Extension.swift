//
//  String+Extension.swift
//  NewWord
//
//  Created by justin on 2024/6/4.
//

import Foundation
import NaturalLanguage

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
    
    func containsWhitespace() -> Bool {
        let whitespaceCharacterSet = CharacterSet.whitespacesAndNewlines
        return rangeOfCharacter(from: whitespaceCharacterSet) != nil
    }
    
    func isSentence() -> Bool {
        // 去除前後空白字符
        let trimmedText = trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 使用NLTokenizer來進行標記化
        let tokenizer = NLTokenizer(unit: .word)
        tokenizer.string = trimmedText
        var wordCount = 0
        
        tokenizer.enumerateTokens(in: trimmedText.startIndex..<trimmedText.endIndex) { tokenRange, _ in
            wordCount += 1
            return true
        }
        
        return wordCount > 1
    }
    
    
}
