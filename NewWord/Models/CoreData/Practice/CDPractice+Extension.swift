//
//  CDPractice+CoreDataProperties.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/9/16.
//
//

import Foundation
import CoreData

@objc(CDPractice)
public class CDPractice: NSManagedObject {

}

extension CDPractice {
    var type: PracticeType? {
        return PracticeType(rawValue: Int(typeRawValue))
    }
    
    var latestPracticeStandardRecord: CDPracticeRecordStandard? {
        guard let standardRecords = record?.standardRecords else {
            return nil
        }
        
        return standardRecords.max { lRecord, rRecord in
            guard let lDueDate = lRecord.dueDate,
                  let rDueDate = rRecord.dueDate else { return false
            }
            return lDueDate < rDueDate
        }
    }
    
    var latestTransitionPracticeStandardRecord: CDPracticeRecordStandard? {
        guard let standardRecords = record?.standardRecords else {
            return nil
        }
        
        var sortedStandardRecords = standardRecords.sorted { lReord, rRecord in
            guard let lReordDate = lReord.dueDate,
                  let rRecordDate = rRecord.dueDate else {
                return false
            }
            
            return lReordDate > rRecordDate
        }
        
        let record = sortedStandardRecords.first { record in
            guard let status = record.status else {
                return false
            }
            
            return status.type == .again || status.type == .easy
        }
        
        return record
    }
    
    var hasLatestTransitionPracticeRecordStandard: Bool {
        return latestTransitionPracticeStandardRecord != nil
    }
    
    var isNew: Bool {
        guard let standardRecords = record?.standardRecords else {
            return false
        }
        
        return standardRecords.isEmpty
    }
    
    var state: PracticeStandardState {
        guard let standardRecords = record?.standardRecords else {
            return .unknown
        }
        
        var sortedStandardRecords = standardRecords.sorted { lReord, rRecord in
            guard let lReordDate = lReord.dueDate,
                  let rRecordDate = rRecord.dueDate else {
                return false
            }
            
            return lReordDate > rRecordDate
        }
        
        
        if sortedStandardRecords.isEmpty {
            return .new
        }
        
        guard let latestStatus = sortedStandardRecords.first?.status,
              let latestState = sortedStandardRecords.first?.state else {
            return .unknown
        }
        
        if latestStatus.type == .again && latestState == .learn {
            return .learning
        }
        
        if let latestTransitionPracticeStandardRecord,
           let state = latestTransitionPracticeStandardRecord.state,
           let status = latestTransitionPracticeStandardRecord.status
        {
            if status.type == .easy {
                return .easyTransition
            } else if status.type == .again {
                return .againTransition
            }
        }
        
        return .unknown
    }
}

extension CDPractice {
    
    // easeBonus * lastDuration * (lastEase + easeAdustment)
    
    func addRecord(userPressedStatusType: PracticeStandardStatusType, referencePractice: CDPractice) {
        let today: Date = Date()
        
        guard let latestRecord = self.latestPracticeStandardRecord,
              let latestStatusType = latestRecord.status?.type,
              let standardPreset = self.preset?.standardPreset
        else {
            return
        }

        let standardRecord = CoreDataManager.shared.createEntity(ofType: CDPracticeRecordStandard.self)
        let referenceStatus = standardPreset.getStatus(from: userPressedStatusType)

        // 如果是新練習和舊練習會有duration差異嗎？不會，有差異的是依據上一次的回答
        
        var duration: Double = 0.0
        var dueDate: Date
        var ease: Double = 2.5
        var learnedDate: Date = Date()
        var newState: PracticeRecordStandardState = .leach
        
        // 當state是new或是learn的時候是使用 state 去新增 record
        
        switch state {
        case .new, .learning:
            guard let firstPracticeInterval = referenceStatus?.firstPracticeInterval else {
                return
            }
            
            duration = firstPracticeInterval
            dueDate = learnedDate.adding(seconds: duration)
            ease = standardPreset.firstPracticeEase
            
            if userPressedStatusType == .easy {
                newState = .review
            }
            
        case .easyTransition:
//            referenceStatus?.easeBonus
//            duration =
            break
            
        case .againTransition:
//            duration =
            break
            
        case .unknown:
            break
        }
        
        standardRecord.duration = duration
    }
}

// 針對整個record
enum PracticeStandardState: Int, CaseIterable {
    case new
    case learning
    case easyTransition
    case againTransition
    case unknown
}

enum PracticeType: Int, CaseIterable {
    case listenAndTranslate
    case listenReadChineseAndTypeEnglish
    case listenAndTypeEnglish
    case readAndTranslate

    var title: String {
        switch self {
        case .listenAndTranslate:
            return "聆聽並翻譯"
        case .listenReadChineseAndTypeEnglish:
            return "聆聽、閱讀中文並輸入英文"
        case .listenAndTypeEnglish:
            return "聆聽並輸入英文"
        case .readAndTranslate:
            return "閱讀並翻譯"
        }
    }
}
