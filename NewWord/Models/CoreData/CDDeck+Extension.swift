//
//  CDDeck+CoreDataProperties.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/9/17.
//
//

import Foundation
import CoreData

enum GenerationType: Int, CaseIterable {
    case userGenerated
    case systemGenerated
}

@objc(CDDeck)
public class CDDeck: NSManagedObject {

}

extension CDDeck {

    var isUserGenerated: Bool {
        return generationType == .userGenerated
    }

    var isSystemGeneratedWithPractice: Bool {
        return generationType == .systemGenerated && hasPractice
    }

    var generationType: GenerationType? {
        guard let type = GenerationType(rawValue: Int(generationTypeRawValue)) else {
            return nil
        }

        return type
    }

    var practiceType: PracticeType? {
        guard let type = PracticeType(rawValue: Int(practiceTypeRawValue)) else {
            return nil
        }
        
        return type
    }

    var hasPractice: Bool {
        return practices.count > 0
    }

    var practices: [CDPractice] {
        guard let practices = self.practiceSet as? Set<CDPractice> else {
            return []
        }

        var filteredPractices = practices.filter { practice in
            guard let mapType = practice.sequence?.map?.type else {
                return true
            }

            return mapType == .practice
        }

        let sortedPractices = Array(filteredPractices).sorted { $0.id < $1.id }

        return sortedPractices
    }
    
    var newPractices: [CDPractice] {
        let newPractices = practices.filter { practice in
            guard practice.isActive else {
                return false
            }
            
            guard let latestPracticeRecordStandard = practice.latestPracticeStandardRecord else {
                return true
            }
            
            return latestPracticeRecordStandard.isDueNew
        }
        
        return newPractices
    }
    
    var reviewPractices: [CDPractice] {
        let reviewPractices = practices.filter { practice in
            guard practice.isActive else {
                return false
            }
            
            guard let latestPracticeRecordStandard = practice.latestPracticeStandardRecord else {
                return false
            }
            
            return latestPracticeRecordStandard.isDueReview
        }
        
        return reviewPractices
    }
    
    var relearnPractices: [CDPractice] {
        let relearnPractices = practices.filter { practice in
            guard practice.isActive else {
                return false
            }
            
            guard let latestPracticeRecordStandard = practice.latestPracticeStandardRecord else {
                return false
            }
            
            return latestPracticeRecordStandard.isDueRelearn
        }
        
        return relearnPractices
    }
}
