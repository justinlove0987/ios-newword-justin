//
//  Tag.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/8/21.
//

import UIKit

enum TextType: Hashable {
    case word
    case sentence
    case article
}

struct Tag {
    enum TagType: Hashable {
        case listenAndTranslate
        case listenReadChineseAndTypeEnglish
        case listenAndTypeEnglish
        case readAndTranslate
    }
    
    let id: String
    let number: Int
    let text: String
    var range: NSRange
    let tagColor: UIColor
    let contentColor: UIColor
    let translatedText: String
    var textType: TextType = .word
    var tagType: TagType = .listenAndTranslate
    
    func getTagIndex(in text: String) -> String.Index? {
        let location = range.location - 1

        if let stringIndex = text.index(text.startIndex, offsetBy: location, limitedBy: text.endIndex) {
            return stringIndex
        }
        
        return nil
    }
}

extension Tag {
    func isEqualTo(_ other: Tag) -> Bool {
        return self.range == other.range &&
               self.textType == other.textType &&
               self.tagType == other.tagType
    }
    
    func isEqualTo(textType: TextType, tagType: TagType, range: NSRange) -> Bool {
        return self.range == range &&
               self.textType == textType &&
               self.tagType == tagType
    }
}
