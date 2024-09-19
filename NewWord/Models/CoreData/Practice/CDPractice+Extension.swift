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
    
    var latestPracticeRecordStandard: CDPracticeRecordStandard? {
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
    
    var latestTransitionPracticeRecordStandard: CDPracticeRecordStandard? {
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
    
    var isNewPractice: Bool {
        guard let standardRecords = record?.standardRecords else {
            return false
        }
        
        return standardRecords.isEmpty
    }
}

extension CDPractice {
    
    // easeBonus * lastDuration * (lastEase + easeAdustment)
    
    
    
    func addRecord(currentStatus: PracticeStatusStandardType) {
        let today: Date = Date()
        
        guard let latestRecord = self.latestPracticeRecordStandard,
              let latestStatusType = latestRecord.status?.type,
              let standardPreset = self.preset?.standardPreset
        else {
            return
        }
        
        standardPreset.firstPracticeEase

        CoreDataManager.shared.createEntity(ofType: CDPracticeRecordStandard.self)

        if isNewPractice {

        }
        
        if let latestRecord = self.latestPracticeRecordStandard {
            
        } else {
            
        }
        
//        latestTransitionPracticeRecordStandard
        
//        switch latestStatusType {
//        case .again:
//            <#code#>
//        case .hard:
//            <#code#>
//        case .good:
//            <#code#>
//        case .easy:
//            <#code#>
//        }
//        
//        switch currentStatus {
//        case .again:
//            <#code#>
//        case .hard:
//            <#code#>
//        case .good:
//            <#code#>
//        case .easy:
//            <#code#>
//        }
        
        
    }
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
