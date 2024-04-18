//
//  ReviewRecord.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/4/13.
//

import Foundation


struct LearningRecord {
    
    enum State {
        case new // 第一次練習
        case relearn // 答錯後在下一次答對前的狀態
        case review // 答錯後第一次答對
    }

    enum TimeUnit {
        case minute
        case hour
        case day

        static let secondsInAMinute = 60
        static let secondsInAnHour = 60 * 60
        static let secondsInADay = 60 * 60 * 24
        static let secondsInAMonth = 2592000
    }

    enum Status {
        case correct
        case incorrect
    }
    
    let createdDate: Date
    let dueDate: Date
    let interval: Int
    let totalTime: Int = 0
    let status: Status
    let state: State
}

extension LearningRecord {
    func getInterval(timeUnit: TimeUnit) -> Int {
        switch timeUnit {
        case .minute:
            let minutes = interval / TimeUnit.secondsInAMinute
            return interval % TimeUnit.secondsInADay == 0 ? minutes : minutes + 1

        case .hour:
            return interval / TimeUnit.secondsInAnHour
        case .day:
            return interval / TimeUnit.secondsInADay
        }
    }

    static func countDueDate() -> Date {
        return Date()
    }

}
