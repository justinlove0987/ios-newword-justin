//
//  Card.swift
//  NewWord
//
//  Created by justin on 2024/3/29.
//

import Foundation

struct Card: Codable {
    let id: String
    var addedDate: Date = Date()
    var averageTime: Int = 0
    var totalTime: Int = 0
    let note: Note
    let learningRecords: [LearningRecord]
}

extension Card {

    enum CardState {
        case new
        case learn
        case review
        case relearn
        case leach
        case master
    }
    
    var reviews: Int {
        return learningRecords
            .filter { $0.state != .relearn }
            .count
    }

    var hasReivews: Bool { return learningRecords.count != 0 }

    /// This is the state existing **prior to** the answer card.
    var currentLearningState: LearningRecord.State? {
        return latestReview?.state
    }
    
    var firstReview: LearningRecord? {
        return learningRecords.min { lRecord, rRecord in
            lRecord.dueDate < rRecord.dueDate
        }
    }
    
    /// If there is no learning record, it means it's a **new card**.
    var latestReview: LearningRecord? {
        return learningRecords.max { lRecord, rRecord in
            lRecord.dueDate < rRecord.dueDate
        }
    }
    
    var firstReviewDate: Date? {
        return firstReview?.learnedDate
    }
    
    var lastestReviewDate: Date? {
        return latestReview?.learnedDate
    }
    
    /// The unit of interval is **second**.
    var interval: Double? {
        return latestReview?.interval
    }
    
    var lapses: Int {
        return learningRecords.reduce(0) { partialResult, record in
            return (record.state == .relearn && record.status == .correct) ? (partialResult + 1) : partialResult
        }
    }
    
    init() {
        self.id = ""
        self.note = Note(id: "", noteType: .sentenceCloze(SentenceCloze(clozeWord: Word(text: "", chinese: ""), sentence: [])))
        self.learningRecords = []
    }
}


extension Card {
    static func createFakeData() -> [Card] {
        let sentences = [
            ["Life", "is", "like", "riding", "a", "bicycle", ".", "To", "keep", "your", "balance", ",", "you", "must", "keep", "moving", "."],
            ["Genius", "is", "one", "percent", "inspiration", "and", "ninety-nine", "percent", "perspiration", "."]
        ]
        
        let sentenceCloze1 = SentenceCloze(clozeWord: Word(text: "like", chinese: "像是我"), sentence: sentences[0])
        let sentenceCloze2 = SentenceCloze(clozeWord: Word(text: "inspiration", chinese: "激發"), sentence: sentences[1])

        let note1 = Note(id: UUID().uuidString, noteType: .sentenceCloze(sentenceCloze1))
        let note2 = Note(id: UUID().uuidString, noteType: .sentenceCloze(sentenceCloze2))

        let date1 = Card.dateCreator(year: 2024, month: 4, day: 28)
        let date2 = Card.dateCreator(year: 2024, month: 5, day: 2)
        let date3 = Card.dateCreator(year: 2024, month: 5, day: 3)

        let card1 = Card(id: UUID().uuidString, note: note1, learningRecords: [])
        let card2 = Card(id: UUID().uuidString, note: note2, learningRecords: [LearningRecord(learnedDate: date1, dueDate: date1, status: .correct, state: .learn),
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
