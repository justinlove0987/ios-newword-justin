//
//  CDPracticeThresholdRule+CoreDataClass.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/9/30.
//
//

import Foundation
import CoreData

enum PracticeThresholdRuleActionType: Int {
    case levelUp
}

enum PracticeThresholdRuleConditionType: Int {
    case totalAgainAttempts
    case cumulativeAgainAttempts
    case totalEasyAttempts
    case cumulativeEasyAttempts
    case nextPracticeIntervalInDays
    
    var title: String {
        switch self {
        case .totalAgainAttempts:
            return "回答重來累績次數"
        case .cumulativeAgainAttempts:
            return "回答重來總次數"
        case .totalEasyAttempts:
            return "回答簡單累績次數"
        case .cumulativeEasyAttempts:
            return "回答簡單總次數"
        case .nextPracticeIntervalInDays:
            return "下一次練習間隔天數"
        }
    }
}

@objc(CDPracticeThresholdRule)
public class CDPracticeThresholdRule: NSManagedObject {

}

extension CDPracticeThresholdRule {
    var actionType: PracticeThresholdRuleActionType? {
        guard let type = PracticeThresholdRuleActionType(rawValue: Int(actionTypeRawValue)) else {
            return nil
        }
        
        return type
    }
    
    var conditionType: PracticeThresholdRuleConditionType? {
        guard let type = PracticeThresholdRuleConditionType(rawValue: Int(conditionTypeRawValue)) else {
            return nil
        }
        
        return type
    }
}
