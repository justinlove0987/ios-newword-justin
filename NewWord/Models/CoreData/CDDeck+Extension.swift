//
//  CDDeck+CoreDataProperties.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/9/17.
//
//

import Foundation
import CoreData


@objc(CDDeck)
public class CDDeck: NSManagedObject {

}

extension CDDeck {
    var practices: [CDPractice] {
        guard let practices = self.practiceSet as? Set<CDPractice> else {
            return []
        }
        
        return Array(practices)
    }
    
    var newPractices: [CDPractice] {
        let newPractices = practices.filter { practice in
            guard let standardArray = practice.record?.standardRecords else {
                return true
            }
            
            return standardArray.isEmpty
        }
        
        return newPractices
    }
    
    var reviewPractices: [CDPractice] {
        let reviewPractices = practices.filter { practice in
            guard let standardRecords = practice.record?.standardRecords,
                  let latestPracticeRecordStandard = practice.latestPracticeStandardRecord
            else {
                return false
            }
            
            return latestPracticeRecordStandard.isTodayReview
        }
        
        return reviewPractices
    }
    
    var relearnPractices: [CDPractice] {
        let relearnPractices = practices.filter { practice in
            guard let standardRecords = practice.record?.standardRecords,
                  let latestPracticeRecordStandard = practice.latestPracticeStandardRecord
            else {
                return false
            }
            
            return latestPracticeRecordStandard.isTodayRelearn
        }
        
        return relearnPractices
    }
}
