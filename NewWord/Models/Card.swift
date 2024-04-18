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
    let averageTime: Int = 0
    let totalTime: Int = 0
    let note: Note
    let learningRecords: [LearningRecord]
}

extension Card {
    
    var hasReivews: Bool { return learningRecords.count != 0 }
    
    var firstReview: LearningRecord? {
        return learningRecords.min { lRecord, rRecord in
            lRecord.dueDate < rRecord.dueDate
        }
    }
    
    var latestReview: LearningRecord? {
        let record = learningRecords.max { lRecord, rRecord in
            lRecord.dueDate < rRecord.dueDate
        }
        
        return (hasReivews ? record : nil)
    }
    
    var firstReviewDate: Date? {
        return firstReview?.createdDate
    }
    
    var lastestReviewDate: Date? {
        return latestReview?.createdDate
    }
    
    var interval: Int? {
        return latestReview?.interval
    }
    
    var reviews: Int { learningRecords.count }
    
    var lapses: Int {
        return learningRecords.reduce(0) { partialResult, record in
            return record.status == .incorrect ? (partialResult + 1) : partialResult
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

        let date1 = Card.dateCreator(year: 2024, month: 5, day: 1)
        let date2 = Card.dateCreator(year: 2024, month: 5, day: 2)
        let date3 = Card.dateCreator(year: 2024, month: 5, day: 3)

        let card1 = Card(id: UUID().uuidString, note: note1, learningRecords: [LearningRecord(createdDate: date1, dueDate: date1, interval: 1, status: .correct, state: .new),
                                                                               LearningRecord(createdDate: date2, dueDate: date2, interval: 2, status: .correct, state: .new),
                                                                               LearningRecord(createdDate: date3, dueDate: date3, interval: 3, status: .correct, state: .new),
                                                                              ])
        let card2 = Card(id: UUID().uuidString, note: note2, learningRecords: [LearningRecord(createdDate: date1, dueDate: date1, interval: 1, status: .correct, state: .new),
                                                                               LearningRecord(createdDate: date2, dueDate: date2, interval: 2, status: .correct, state: .new),
                                                                               LearningRecord(createdDate: date3, dueDate: date3, interval: 3, status: .correct, state: .new),
                                                                              ])

        return [card1, card2]
    }

    static func dateCreator(year: Int, month: Int, day: Int) -> Date {
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day

        let calendar = Calendar.current

        return calendar.date(from: dateComponents)!
    }
}
