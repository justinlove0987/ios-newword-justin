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
    var practiceArray: [CDPractice] {
        guard let practices = self.practices as? Set<CDPractice> else {
            return []
        }
        
        return Array(practices)
    }
    
    var newPractices: [CDPractice] {
        let newPractices = practiceArray.filter { practice in
            guard let standardArray = practice.record?.standardArray else {
                return false
            }
            
            return standardArray.isEmpty
        }
        
        return []
    }
    
    
}
