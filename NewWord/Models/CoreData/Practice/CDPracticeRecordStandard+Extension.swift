//
//  CDPracticeRecordStandard+CoreDataClass.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/9/17.
//
//

import Foundation
import CoreData

@objc(CDPracticeRecordStandard)
public class CDPracticeRecordStandard: NSManagedObject {

}

extension CDPracticeRecordStandard {
    var state: PracticeRecordStandardState? {
        return PracticeRecordStandardState(rawValue: Int(stateRawValue))
    }
    
    var isTodayReview: Bool {
        guard let dueDate = dueDate,
              let status = status,
              let state = state else {
            return false
        }
        
        return dueDate <= Date() &&
        status.type == .easy &&
        (state == .learn ||
         state == .review)
    }
    
    var isTodayRelearn: Bool {
        guard let dueDate = dueDate,
              let status = status,
              let state = state else {
            return false
        }
        
        return dueDate <= Date() &&
        status.type == .again &&
        (state == .learn ||
         state == .relearn)
    }
}

enum PracticeRecordStandardState: Int, CaseIterable {
    case learn
    case review
    case relearn
    case leach
    case master
}
