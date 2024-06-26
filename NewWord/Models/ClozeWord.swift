//
//  ClozeWord.swift
//  NewWord
//
//  Created by justin on 2024/6/25.
//

import Foundation


struct ClozeWord {

    enum WordType {
        case none
        case cloze
        case multiCloze
    }

    var type: WordType = .none

    var selected: Bool = false

    var clozeNumber: Int?

    let position: (sentenceIndex: Int, wordIndex: Int)

    var text: String
}
