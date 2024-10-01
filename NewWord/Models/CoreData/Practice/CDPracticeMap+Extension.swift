//
//  CDPracticeMap+CoreDataProperties.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/9/16.
//
//


import Foundation
import CoreData

enum PracticeMapType: Int, CaseIterable {
    case practice
    case blueprintForArticleWord
    
    var practiceBlueprint: [[PracticeType]]? {
        switch self {
        case .blueprintForArticleWord:
            return [[.listenAndTranslate, .readClozeAndTypeEnglish]]
            
        default:
            return nil
        }
    }
}

@objc(CDPracticeMap)
public class CDPracticeMap: NSManagedObject {

}

extension CDPracticeMap {
    var type: PracticeMapType? {
        return PracticeMapType(rawValue: Int(typeRawValue))
    }
    
    var sortedSequences: [CDPracticeSequence] {
        guard let sequences = self.sequenceSet as? Set<CDPracticeSequence> else {
            return []
        }

        let sortedSequences = sequences.sorted { $0.level < $1.level }
        return sortedSequences
    }
    
    var greatestLevelSequence: CDPracticeSequence? {
        return sortedSequences.last
    }
    
    var hasPractice: Bool {
        for sequence in sortedSequences {
            if sequence.sortedPractices.count > 0 {
                return true
            }
        }
        
        return false
    }
}


