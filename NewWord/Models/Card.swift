//
//  Card.swift
//  NewWord
//
//  Created by justin on 2024/3/29.
//

import Foundation

struct Card {
    let id: String
    let addedDate: Date = Date()
    let dueDate: Date = Date() // 需要考量怎麼計算，透過 latestReview.date + latestReview.interval
    let averageTime: Int = 0
    let totalTime: Int = 0
    let note: Note
    let learningRecords: [LearningRecord]
}

extension Card {
    enum CardState {
        case new
        case review
    }
    
    var reviews: Int { learningRecords.count }
    
    var hasReivews: Bool { return learningRecords.count != 0 }
    
    var cardState: CardState {
        return hasReivews ? .review : .new
    }
    
    var firstReview: LearningRecord? {
        return learningRecords.min { lRecord, rRecord in
            lRecord.dueDate < rRecord.dueDate
        }
    }
    
    var latesReview: LearningRecord? {
        let record = learningRecords.max { lRecord, rRecord in
            lRecord.dueDate > rRecord.dueDate
        }
        
        return (hasReivews ? record : nil)
    }
    
    var firstReviewDate: Date? {
        return firstReview?.date
    }
    
    var lastestReviewDate: Date? {
        return latesReview?.date
    }
    
    var interval: Double? {
        return latesReview?.interval
    }
    
    var lapses: Int {
        return learningRecords.reduce(0) { partialResult, record in
            return record.isCorrect ? (partialResult + 1) : partialResult
        }
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
        let card1 = Card(id: UUID().uuidString, note: note1, learningRecords: [])
        let card2 = Card(id: UUID().uuidString, note: note2, learningRecords: [])
        
        return [card1, card2]
    }
}
