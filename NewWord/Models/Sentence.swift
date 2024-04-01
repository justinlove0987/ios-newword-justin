//
//  Sentence.swift
//  NewWord
//
//  Created by justin on 2024/4/1.
//

import Foundation

struct Sentence {
    let words: [Word]
}

extension Sentence {
    static func createFakeData() -> [Sentence] {
        let sentences = [
            ["Life", "is", "like", "riding", "a", "bicycle", ".", "To", "keep", "your", "balance", ",", "you", "must", "keep", "moving", "."],
            ["Genius", "is", "one", "percent", "inspiration", "and", "ninety-nine", "percent", "perspiration", "."]
        ]

        let wordsInSentences: [Sentence] = sentences.map({ words in
            let words = words.map { word in
                if word == "like" || word == "one" {
                    return Word(text: word, isReview: true)
                } else {
                    return Word(text: word, isReview: false)
                }
            }

            return Sentence(words: words)
        })

        print(wordsInSentences)

        return wordsInSentences
    }
}

