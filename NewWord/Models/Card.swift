//
//  Card.swift
//  NewWord
//
//  Created by justin on 2024/3/29.
//

import Foundation

struct Card {
    let cardId: String
    let addedDate: Date = Date()
    let firstReviewDate: Date = Date()
    let lastestReviewDate: Date = Date()
    let dueDate: Date = Date()
    let interval: Int
    let reviews: Int = 0
    let lapses: Int = 0
    let averageTime: Int = 0
    let totalTime: Int = 0
    let note: Note
    let reviewRecords: [ReviewRecord]
}

extension Card {
    enum CardState {
        case new
        case review
    }

    var cardState: CardState {
        if reviews == 0 {
            return .new
        }

        return .review
    }
}


extension Card {
    static func createFakeData() -> [Card] {
        let sentences = [
            ["Life", "is", "like", "riding", "a", "bicycle", ".", "To", "keep", "your", "balance", ",", "you", "must", "keep", "moving", "."],
            ["Genius", "is", "one", "percent", "inspiration", "and", "ninety-nine", "percent", "perspiration", "."]
        ]

        let sentenceCloze1 = SentenceCloze(clozeWord: Word(text: "like", isReview: false), sentence: sentences[0])
        let sentenceCloze2 = SentenceCloze(clozeWord: Word(text: "one", isReview: false), sentence: sentences[1])
        
        let note1 = Note(noteId: UUID().uuidString, noteType: .sentenceCloze(sentenceCloze1))
        let note2 = Note(noteId: UUID().uuidString, noteType: .sentenceCloze(sentenceCloze2))
        let card1 = Card(cardId: UUID().uuidString, interval: 0, note: note1, reviewRecords: [])
        let card2 = Card(cardId: UUID().uuidString, interval: 0, note: note2, reviewRecords: [])

        return [card1, card2]
    }
}
