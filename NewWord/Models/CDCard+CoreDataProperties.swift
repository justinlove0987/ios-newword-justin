//
//  CDCard+CoreDataProperties.swift
//  NewWord
//
//  Created by justin on 2024/5/27.
//
//

import Foundation
import CoreData


extension CDCard {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDCard> {
        return NSFetchRequest<CDCard>(entityName: "CDCard")
    }

    @NSManaged public var addedDate: Date?
    @NSManaged public var id: String?
    @NSManaged public var deck: CDDeck?
    @NSManaged public var note: CDNote?
    @NSManaged public var learningRecords: NSSet?

}

// MARK: Generated accessors for learningRecords
extension CDCard {

    @objc(addLearningRecordsObject:)
    @NSManaged public func addToLearningRecords(_ value: CDLearningRecord)

    @objc(removeLearningRecordsObject:)
    @NSManaged public func removeFromLearningRecords(_ value: CDLearningRecord)

    @objc(addLearningRecords:)
    @NSManaged public func addToLearningRecords(_ values: NSSet)

    @objc(removeLearningRecords:)
    @NSManaged public func removeFromLearningRecords(_ values: NSSet)

}

extension CDCard : Identifiable {

}
