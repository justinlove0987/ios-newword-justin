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
    var latestLearningRecord: CDLearningRecord? {

        let persistentContainer = CoreDataManager.shared.persistentContainer

        let request: NSFetchRequest<CDLearningRecord> = CDLearningRecord.fetchRequest()
        request.predicate = NSPredicate(format: "card = %@", self)

        var learningRecords: [CDLearningRecord] = []

        learningRecords = (try? persistentContainer.viewContext.fetch(request)) ?? []

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
