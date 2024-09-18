//
//  CDPracticeSequence+CoreDataProperties.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/9/16.
//
//

import Foundation
import CoreData

@objc(CDPracticeSequence)
public class CDPracticeSequence: NSManagedObject {

}

extension CDPracticeSequence {
    var sortedPractices: [CDPractice] {
        guard let practices = self.practices as? Set<CDPractice> else {
            return []
        }
        
        let sortedPractices = practices.sorted { $0.sequenceOrder < $1.sequenceOrder }
        return sortedPractices
    }
}
