//
//  ReviewRecord.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/4/13.
//

import Foundation


enum State: String, Codable {
    case learn
    case review
    case relearn
    case leach
    case master
    
    enum CodingKeys: String, CodingKey {
        case learn
        case review
        case relearn
        case leach
        case master
    }
}


struct LearningRecord: Hashable,Codable {

    enum State: String, Codable {
        case learn
        case review
        case relearn
        case leach
        case master
        
        enum CodingKeys: String, CodingKey {
            case learn
            case review
            case relearn
            case leach
            case master
        }
    }

    enum Status: String, Codable {
        case correct
        case incorrect
        
        enum CodingKeys: String, CodingKey {
            case correct
            case incorrect
        }
    }
        
    let learnedDate: Date
    let dueDate: Date
    var totalTime: Int = 0
    let status: Status

    /// This is the state **after** the answer card.
    let state: State

    var ease: Double = 2.5
}

extension LearningRecord {
    
    /// The unit of interval is **second**.
    var interval: Double {
        return dueDate.timeIntervalSince(learnedDate) // seconds
    }

    static func countDueDate() -> Date {
        return Date()
    }
    

    static func createLearningRecord(lastCard: Card, deck: Deck, isAnswerCorrect: Bool) -> LearningRecord {

        let today: Date = Date()

        // TODO: - 在新增learningRecord時增加說明
        // TODO: - 調整 latestReview ease
        // TODO: - 將答錯時，ease需要加上的趴數獨立出來
        // TODO: - 需要調整 ease
        // TODO: - 修改 dueDate 應該是 today 加上 computed interval

        guard let latestReview = lastCard.latestReview else {
            // When we don't have latest reivew, then it's a new card.
            let newCard = deck.newCard
            let currentLearningStatus: LearningRecord.Status = isAnswerCorrect ? .correct : .incorrect

            let dueDate: Date = isAnswerCorrect ? addInterval(to: today, dayInterval: newCard.easyInterval)! : addInterval(to: today, secondInterval: newCard.learningStpes)

            return LearningRecord(learnedDate: today, dueDate: dueDate, status: currentLearningStatus, state: .learn)
        }
        
        let lastStatus =  latestReview.status
        let lastState = latestReview.state
        
        let dueDate: Date
        let newStatus: LearningRecord.Status
        let newState: LearningRecord.State
        
        if isAnswerCorrect {
            newStatus = .correct
            
            if LearningRecord.isMasterCard(lastCard: lastCard, deck: deck) {
                let newInterval = latestReview.interval * (latestReview.ease + 0.2)
                dueDate = today.addingTimeInterval(newInterval)
                newState = .master
                
            } else {
                switch (lastState, lastStatus) {
                case (.learn, .correct), (.review, .correct), (.relearn, .correct):
                    let newInterval = latestReview.interval * (latestReview.ease + 0.2)
                    dueDate = today.addingTimeInterval(newInterval)
                    newState = .review
                case (.learn, .incorrect):
                    let interval = deck.newCard.graduatingInterval
                    dueDate = addInterval(to: today, dayInterval: interval)!
                    newState = .learn
                case (.review, .incorrect), (.relearn, .incorrect):
                    let newInterval = 1
                    dueDate = addInterval(to: today, dayInterval: newInterval)!
                    newState = .relearn
                default:
                    fatalError("Unknown state!")
                }
            }
            
        } else {
            newStatus = .incorrect
            
            if LearningRecord.isLeachCard(lastCard: lastCard, deck: deck) {
                dueDate = today
                newState = .leach
                
            } else {
                switch (lastState, lastStatus) {
                case (.learn, .correct), (.review, .correct), (.relearn, .correct):
                    let relearningStpes = deck.lapses.relearningSteps
                    dueDate = addInterval(to: today, secondInterval: relearningStpes)
                    newState = .review
                    
                case (.learn, .incorrect):
                    let interval = deck.lapses.relearningSteps
                    dueDate = addInterval(to: today, secondInterval: interval)
                    newState = .learn
                    
                case (.review, .incorrect), (.relearn, .incorrect):
                    let interval = deck.lapses.relearningSteps
                    dueDate = addInterval(to: today, secondInterval: interval)
                    newState = .relearn
                    
                default:
                    fatalError("Unknown state!")
                }
                
                return LearningRecord(learnedDate: today, dueDate: dueDate, status: newStatus, state: newState)
                
            }
        }


        return LearningRecord(learnedDate: today, dueDate: dueDate, status: newStatus, state: newState)
    }

    static func addInterval(to date: Date, dayInterval: Int) -> Date? {
        let interval: Int = dayInterval

        var dateComponents = DateComponents()
        dateComponents.day = interval

        let calendar = Calendar.current
        let futureDate = calendar.date(byAdding: dateComponents, to: date)

        return futureDate
    }

    static func addInterval(to date: Date, secondInterval: Double) -> Date {
        return date.addingTimeInterval(secondInterval)
    }
    
    private func createInterval() {
        
    }
}

extension LearningRecord {
    static func isLeachCard(lastCard: Card, deck: Deck, answerIsCorrect: Bool = false) -> Bool {
        let filteredRecords = lastCard.learningRecords.filter { reocrd in
            return reocrd.state == .relearn && reocrd.status == .correct
        }

        return filteredRecords.count + 1 >= deck.lapses.leachThreshold
    }

    static func isMasterCard(lastCard: Card, deck: Deck, answerIsCorrect: Bool = true) -> Bool {
        let filteredRecords = lastCard.learningRecords.filter { reocrd in
            return reocrd.status == .correct
        }

        return filteredRecords.count + 1 >= deck.master.consecutiveCorrects
    }


    func createInterval(lastLearningRedord: LearningRecord, isAnwerCorrect: Bool) {

    }
}
