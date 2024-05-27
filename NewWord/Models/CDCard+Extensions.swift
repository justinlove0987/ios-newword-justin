//
//  CDCard+Extensions.swift
//  NewWord
//
//  Created by justin on 2024/5/27.
//

import Foundation
import CoreData

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
