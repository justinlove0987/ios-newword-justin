//
//  CDCard+Extension.swift
//  NewWord
//
//  Created by justin on 2024/5/31.
//

import Foundation

import Foundation
import CoreData

@objc(CDCard)
public class CDCard: NSManagedObject {

}

extension CDCard {
    
    var totalTime: Double {
        let learningRecords = CoreDataManager.shared.learningRecords(from: self)
        
        guard !learningRecords.isEmpty else {
            return 0.0
        }
        
        let totalSum = learningRecords.map { $0.time }.reduce(0, +)
        
        return totalSum
    }
    
    var averageTime: Double {
        let learningRecords = CoreDataManager.shared.learningRecords(from: self)
        
        guard !learningRecords.isEmpty else {
            return 0.0
        }
        
        let totalSum = learningRecords.map { $0.time }.reduce(0, +)
        let averageTime = totalSum / Double(learningRecords.count)
        
        return averageTime
        
    }
    
    var lapses: Int {
        let learningRecords = CoreDataManager.shared.learningRecords(from: self)
        
        let lapsesRecords = learningRecords.filter { record in
            return record.status == .incorrect
        }
        
        return lapsesRecords.count
    }
    
    var reviews: Int {
        let learningRecords = CoreDataManager.shared.learningRecords(from: self)
        
        return learningRecords.count
    }
    
    var firstLearningRecord: CDLearningRecord? {
        let learningRecords = CoreDataManager.shared.learningRecords(from: self)
        
        return learningRecords.min { lRecord, rRecord in
            lRecord.dueDate! < rRecord.dueDate!
        }
    }
    
    var latestLearningRecord: CDLearningRecord? {
        let learningRecords = CoreDataManager.shared.learningRecords(from: self)

        return learningRecords.max { lRecord, rRecord in
            lRecord.dueDate! < rRecord.dueDate!
        }
    }
    
    func isMasterCard(belongs deck: CDDeck, answerIsCorrect: Bool = true) -> Bool {
        let learningRecords = CoreDataManager.shared.learningRecords(from: self)
        
        let filteredRecords = learningRecords.filter { record in
            return record.status == .correct
        }

        return filteredRecords.count + 1 >= Int(deck.preset!.master!.consecutiveCorrects)
    }
    
    func isLeachCard(belongs deck: CDDeck, answerIsCorrect: Bool = false) -> Bool {
        let learningRecords = CoreDataManager.shared.learningRecords(from: self)
        
        let filteredRecords = learningRecords.filter { record in
            return record.state == .relearn && record.status == .correct
        }

        return filteredRecords.count + 1 >= Int(deck.preset!.lapses!.leachThreshold)
    }

}
