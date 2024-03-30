//
//  Vacabulary.swift
//  NewWord
//
//  Created by justin on 2024/3/29.
//

import Foundation

enum PartOfSpeech {
    case noun
    case verb
}

struct Vacabulary {
    let text: String
    let range: NSRange
    var needReview: Bool
    //    let partOfSpeech: PartOfSpeech
    //    let pastTense: String
}
