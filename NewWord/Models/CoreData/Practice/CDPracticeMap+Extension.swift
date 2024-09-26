//
//  CDPracticeMap+CoreDataProperties.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/9/16.
//
//


import Foundation
import CoreData

@objc(CDPracticeMap)
public class CDPracticeMap: NSManagedObject {

}

extension CDPracticeMap {
    var type: PracticeMapType? {
        return PracticeMapType(rawValue: Int(typeRawValue))
    }
    
    var sortedSequences: [CDPracticeSequence] {
        guard let sequences = self.sequences as? Set<CDPracticeSequence> else {
            return []
        }

        let sortedSequences = sequences.sorted { $0.level < $1.level }
        return sortedSequences
    }
    
    var greatestLevelSequence: CDPracticeSequence? {
        return sortedSequences.last
    }
}

enum PracticeMapType: Int, CaseIterable {
    case blueprint
}
