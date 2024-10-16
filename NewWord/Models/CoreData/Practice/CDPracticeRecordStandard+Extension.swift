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
    
    var formattedInterval: String {
        let minute: TimeInterval = 60
        let hour: TimeInterval = minute * 60
        let day: TimeInterval = hour * 24
        let month: TimeInterval = day * 30.44 // 平均一個月的天數
        let year: TimeInterval = day * 365.25 // 平均一年的天數

        switch duration {
        case let x where x >= year:
            // 超過1年，顯示幾年，取到小數點後兩位
            return String(format: "%.2f年", duration / year)
        case let x where x >= month:
            // 超過1個月，顯示幾個月，取到小數點後兩位
            return String(format: "%.2f個月", duration / month)
        case let x where x >= day:
            // 超過1天，顯示幾天，不用小數點
            return String(format: "%.0f天", duration / day)
        case let x where x >= hour:
            // 超過1小時，顯示幾小時，取到小數點後1位
            return String(format: "%.1f小時", duration / hour)
        case let x where x >= minute:
            // 超過1分鐘，顯示幾分鐘
            return String(format: "%.0f分鐘", duration / minute)
        default:
            // 小於1分鐘，直接顯示秒數
            return String(format: "%.0f秒", duration)
        }
    }
    
    var formattedEase: String {
        return String(format: "%.0f%%", ease * 100)
    }
    
    var formattedLearnedDate: String? {
        guard let learnedDate = learnedDate else {
            return nil
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        return dateFormatter.string(from: learnedDate)
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
    
    var title: String {
        switch self {
        case .new:
            return "新卡片"
        case .learn:
            return "學習"
        case .review:
            return "複習"
        case .relearn:
            return "重新學習"
        case .leach:
            return "-"
        case .master:
            return "-"
        }
    }
}
