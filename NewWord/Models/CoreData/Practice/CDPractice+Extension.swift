//
//  CDPractice+CoreDataProperties.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/9/16.
//
//

import Foundation
import CoreData

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
    
    var isRelearnPractice: Bool {
        guard let latestPracticeStandardRecord else { return false }
        
        return latestPracticeStandardRecord.stateType == .learn
    }
}

extension CDPractice {
    
    func addRecord(userPressedStatusType: PracticeStandardStatusType,
                   standardPreset: CDPracticePresetStandard) {

        let referenceStatus = standardPreset.getStatus(from: userPressedStatusType)

        guard let learnedDate = calculateLearnedDate(),
              let referenceStatus = referenceStatus,
              let latestPracticeStandardRecord
        else {
            return
        }

        let (newEase, newDuration, newDueDate, newRecordState) = calculateNewValues(
            referenceStatus: referenceStatus,
            latestRecord: latestPracticeStandardRecord,
            standardPreset: standardPreset
        )

        saveStandardRecord(
            newEase: newEase,
            newDuration: newDuration,
            learnedDate: learnedDate,
            newDueDate: newDueDate,
            newStateType: newRecordState,
            newStatusType: userPressedStatusType
        )
    }

    private func calculateLearnedDate() -> Date? {
        return Date() // 可以根據需求自定義learnedDate邏輯
    }

    private func calculateNewValues(
        referenceStatus: CDPracticeStatus,
        latestRecord: CDPracticeRecordStandard,
        standardPreset: CDPracticePresetStandard
    ) -> (newEase: Double, newDuration: Double, newDueDate: Date, newRecordState: PracticeRecordStandardStateType) {

        var newEase: Double = latestRecord.ease
        var newDuration: Double = 0.0
        var newDueDate: Date = Date()
        var newRecordState: PracticeRecordStandardStateType = .relearn

        let learnedDate = Date()

        switch latestRecord.intervalType {
            
        case .new, .firstPractice:
            newEase = standardPreset.firstPracticeEase
            newDuration = referenceStatus.firstPracticeInterval
            newDueDate = learnedDate.adding(seconds: newDuration)
            newRecordState = .learn

        case .forget:
            newEase += referenceStatus.easeAdjustment
            newDuration = referenceStatus.forgetInterval
            newDueDate = learnedDate.adding(seconds: newDuration)
            newRecordState = referenceStatus.type == .easy ? .review : .relearn

        case .remember:
            newEase += referenceStatus.easeAdjustment
            newDuration = newEase * referenceStatus.easeBonus * latestRecord.duration
            newDueDate = learnedDate.adding(seconds: newDuration)
            newRecordState = referenceStatus.type == .again ? .relearn : .review

        default:
            newEase = standardPreset.firstPracticeEase
            newDuration = referenceStatus.firstPracticeInterval
            newDueDate = learnedDate.adding(seconds: newDuration)
            newRecordState = .learn
        }

        return (newEase, newDuration, newDueDate, newRecordState)
    }

    private func saveStandardRecord(
        newEase: Double,
        newDuration: Double,
        learnedDate: Date,
        newDueDate: Date,
        newStateType: PracticeRecordStandardStateType,
        newStatusType: PracticeStandardStatusType
    ) {
        let standardRecord = CoreDataManager.shared.createEntity(ofType: CDPracticeRecordStandard.self)
        standardRecord.duration = newDuration
        standardRecord.learnedDate = learnedDate
        standardRecord.dueDate = newDueDate
        standardRecord.stateRawValue = newStateType.rawValue.toInt64
        standardRecord.statusRawValue = newStatusType.rawValue.toInt64

        self.record?.addToStandardRecordSet(standardRecord)

        CoreDataManager.shared.save()
    }

    func getInterval(at order: Int, standardPreset: CDPracticePresetStandard) -> Double? {
        guard let statusType = PracticeStandardStatusType(rawValue: order) else { return nil }

        let referenceStatus = standardPreset.getStatus(from: statusType)

        guard let referenceStatus = referenceStatus,
              let latestPracticeStandardRecord
        else {
            return nil
        }

        let newValues = calculateNewValues(
            referenceStatus: referenceStatus,
            latestRecord: latestPracticeStandardRecord,
            standardPreset: standardPreset
        )

        return newValues.newDuration
    }
}
