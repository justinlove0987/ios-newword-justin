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
