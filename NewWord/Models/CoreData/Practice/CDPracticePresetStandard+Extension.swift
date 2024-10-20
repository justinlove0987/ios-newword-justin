//
//  CDPracticePresetStandard+CoreDataClass.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/9/19.
//
//

import Foundation
import CoreData

@objc(CDPracticePresetStandard)
public class CDPracticePresetStandard: NSManagedObject {

}

extension CDPracticePresetStandard {
    var statuses: [CDPracticeStatus] {
        guard let statusSet = self.statusSet as? Set<CDPracticeStatus> else {
            return []
        }
        
        return Array(statusSet)
    }
    
    var sortedStatuses: [CDPracticeStatus] {
        return statuses.sorted { $0.order < $1.order }
    }
    
    var thresholdRules: [CDPracticeThresholdRule] {
        guard let thresholdRules = self.thresholdRuleSet as? Set<CDPracticeThresholdRule> else {
            return []
        }
        
        return Array(thresholdRules)
    }
    
    func hasReachedThresholdCondition(_ practice: CDPractice) -> Bool {
        guard let record = practice.record,
              let latestInterval = practice.latestPracticeStandardRecord?.interval else {
            return false
        }
        
        for threshold in thresholdRules {
            guard let conditionType = threshold.conditionType else {
                continue
            }
            
            let conditionValue = Int(threshold.conditionValue)
            
            if isConditionMet(conditionType, with: conditionValue, record: record, latestInterval: latestInterval) {
                return true
            }
        }
        
        return false
    }

    private func isConditionMet(_ conditionType: PracticeThresholdRuleConditionType, with conditionValue: Int, record: CDPracticeRecord, latestInterval: Double) -> Bool {
        switch conditionType {
        case .totalEasyAttempts:
            return record.totalEasyAttempts >= conditionValue
        case .totalAgainAttempts:
            return record.totalAgainAttempts >= conditionValue
        case .cumulativeEasyAttempts:
            return record.cumulativeEasyAttempts >= conditionValue
        case .cumulativeAgainAttempts:
            return record.cumulativeAgainAttempts >= conditionValue
        case .nextPracticeIntervalInDays:
            return latestInterval >= daysToSeconds(conditionValue)
        }
    }

    private func daysToSeconds(_ days: Int) -> Double {
        return Double(days) * 24 * 60 * 60
    }
    
    func getStatus(from userPressedStatus: PracticeStandardStatusType) -> CDPracticeStatus? {
        for status in statuses {
            if status.type == userPressedStatus {
                return status
            }
        }
        
        return nil
    }
}
