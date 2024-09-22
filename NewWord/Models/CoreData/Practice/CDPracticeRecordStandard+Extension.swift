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
    var stateType: PracticeRecordStandardStateType? {
        return PracticeRecordStandardStateType(rawValue: Int(stateRawValue))
    }
    
    var statusType: PracticeStandardStatusType? {
        return PracticeStandardStatusType(rawValue: Int(statusRawValue))
    }

    var intervalType: PracticeStandardIntervalType? {
        guard let statusType = statusType,
              let stateType = stateType else {
            return nil
        }

        switch (stateType, statusType) {
        case (.new, .again):
            return .new
            
        case (.learn, .again), (.learn, .hard), (.learn, .good):
            return .firstPractice // 上一次練習在第一次練習期間

        case (.relearn, .again), (.relearn, .hard), (.relearn, .good), (.review, .again):
            return .forget // 上一次的練習是錯誤的

        case (.learn, .easy), (.relearn, .easy), (.review, .hard), (.review, .good), (.review, .easy):
            return .remember // 上一次的練習是正確的

        case (_,_):
            return .unknown
        }
    }
    
    var isDueNew: Bool {
        guard let dueDate = dueDate else {
            return false
        }
        
        return dueDate <= Date() && stateType == .new
    }

    var isDueReview: Bool {
        guard let dueDate = dueDate else {
            return false
        }
        
        return dueDate <= Date() && intervalType == .remember
    }
    
    var isDueRelearn: Bool {
        guard let dueDate = dueDate else {
            return false
        }
        
        return dueDate <= Date() && (intervalType == .forget || intervalType == .firstPractice)
    }
}

enum PracticeStandardIntervalType: Int, CaseIterable {
    case new
    case firstPractice
    case forget
    case remember
    case unknown
}

enum PracticeRecordStandardStateType: Int, CaseIterable {
    case new
    case learn
    case review
    case relearn
    case leach
    case master
}
