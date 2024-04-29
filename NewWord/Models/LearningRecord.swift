//
//  ReviewRecord.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/4/13.
//

import Foundation


struct LearningRecord {

    enum State {
        case learn
        case review
        case relearn
        case leach
        case master
    }

    enum Status {
        case correct
        case incorrect
    }
    
    let learnedDate: Date
    let dueDate: Date
    let totalTime: Int = 0
    let status: Status

    /// This is the state **after** the answer card.
    let state: State

    let ease: Double = 2.5
}

extension LearningRecord {
    
    /// The unit of interval is **second**.
    var interval: Double {
        return dueDate.timeIntervalSince(learnedDate) // seconds
    }

    static func countDueDate() -> Date {
        return Date()
    }
    

    func createLearningRecord(card: Card, deck: Deck, isAnswerCorrect: Bool) -> LearningRecord {

        let today: Date = Date()
        let currentLearningStatus: LearningRecord.Status = isAnswerCorrect ? .correct : .incorrect

        guard let latestReview = card.latestReview else {
            // When we don't have latest reivew, then it's a new card.
            let newCard = deck.newCard

            let dueDate: Date = isAnswerCorrect ? addInterval(to: today, dayInterval: newCard.easyInterval)! : addInterval(to: today, secondInterval: newCard.learningStpes)

            return LearningRecord(learnedDate: today, dueDate: dueDate, status: currentLearningStatus, state: .learn)
        }


        return LearningRecord(learnedDate: today, dueDate: today, status: .correct, state: .learn)
    }

    private func addInterval(to date: Date, dayInterval: Int) -> Date? {
        let interval: Int = dayInterval

        var dateComponents = DateComponents()
        dateComponents.day = interval

        let calendar = Calendar.current
        let futureDate = calendar.date(byAdding: dateComponents, to: date)

        return futureDate
    }

    private func addInterval(to date: Date, secondInterval: Double) -> Date {
        return date.addingTimeInterval(secondInterval)
    }
}
