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

}
