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
        guard let practices = self.practiceSet as? Set<CDPractice> else {
            return []
        }
        
        let sortedPractices = practices.sorted { $0.order < $1.order }
        return sortedPractices
    }
}
