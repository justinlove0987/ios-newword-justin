//
//  NoteType.swift
//  NewWord
//
//  Created by justin on 2024/4/12.
//

import Foundation


struct SentenceCloze: Codable {
    var clozeWord: Word
    var sentence: Sentence
}

extension SentenceCloze {
    init(clozeWord: Word, sentence: [String]) {
        let words: [Word] = sentence.reduce([]) { partialResult, word in
            var result = partialResult
            result.append(Word(text: word, chinese: ""))
            return result
        }

        self.sentence = Sentence(words: words)
        self.clozeWord = clozeWord
    }
}

enum NoteType: Codable {
    case sentenceCloze(SentenceCloze)
    
    enum CodingKeys: String, CodingKey {
        case sentenceCloze
    }
}
