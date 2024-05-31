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
    var latestReview: CDLearningRecord? {

        let persistentContainer = CoreDataManager.shared.persistentContainer

        let request: NSFetchRequest<CDLearningRecord> = CDLearningRecord.fetchRequest()
        request.predicate = NSPredicate(format: "card = %@", self)

        var learningRecords: [CDLearningRecord] = []

        learningRecords = (try? persistentContainer.viewContext.fetch(request)) ?? []

        return learningRecords.max { lRecord, rRecord in
            lRecord.dueDate! < rRecord.dueDate!
        }
    }
}
