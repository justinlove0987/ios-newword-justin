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
    
    var latestTransitionPracticeStandardRecord: CDPracticeRecordStandard? {
        guard let standardRecords = record?.standardRecords else {
            return nil
        }

        let sortedStandardRecords = standardRecords.sorted { lReord, rRecord in
            guard let lReordDate = lReord.dueDate,
                  let rRecordDate = rRecord.dueDate else {
                return false
            }

            return lReordDate > rRecordDate
        }

        let record = sortedStandardRecords.first { record in
            guard let status = record.status,
                  let state = record.stateType
            else {
                return false
            }

            return (status.type == .again || status.type == .easy) && state != .learn
        }

        return record
    }

    var isNew: Bool {
        guard let standardRecords = record?.standardRecords else {
            return false
        }
        
        return standardRecords.isEmpty
    }
}

extension CDPractice {
    
    func addRecord(userPressedStatusType: PracticeStandardStatusType,
                   standardPreset: CDPracticePresetStandard) {

        let referenceStatus = standardPreset.getStatus(from: userPressedStatusType)

        guard let learnedDate = calculateLearnedDate(),
              let referenceStatus = referenceStatus else {
            return
        }

        let (newEase, newDuration, newDueDate, newRecordState) = calculateNewValues(
            referenceStatus: referenceStatus,
            latestRecord: self.latestPracticeStandardRecord,
            userPressedStatusType: userPressedStatusType,
            standardPreset: standardPreset
        )

        saveStandardRecord(
            newEase: newEase,
            newDuration: newDuration,
            learnedDate: learnedDate,
            newDueDate: newDueDate,
            newRecordState: newRecordState,
            referenceStatus: referenceStatus.copy()
        )
    }

    private func calculateLearnedDate() -> Date? {
        return Date() // 可以根據需求自定義learnedDate邏輯
    }

    private func calculateNewValues(
        referenceStatus: CDPracticeStatus,
        latestRecord: CDPracticeRecordStandard?,
        userPressedStatusType: PracticeStandardStatusType,
        standardPreset: CDPracticePresetStandard
    ) -> (newEase: Double, newDuration: Double, newDueDate: Date, newRecordState: PracticeRecordStandardStateType) {

        var newEase: Double = latestRecord == nil ? standardPreset.firstPracticeEase : latestRecord!.ease
        var newDuration: Double = 0.0
        var newDueDate: Date = Date()
        var newRecordState: PracticeRecordStandardStateType = .relearn

        let learnedDate = Date()
        
        if isNew {
            newEase = standardPreset.firstPracticeEase
            newDuration = referenceStatus.firstPracticeInterval
            newDueDate = learnedDate.adding(seconds: newDuration)
            newRecordState = .learn

            return (newEase, newDuration, newDueDate, newRecordState)
        }

        switch latestRecord!.intervalType {

        case .firstPractice:
            newEase = standardPreset.firstPracticeEase
            newDuration = referenceStatus.firstPracticeInterval
            newDueDate = learnedDate.adding(seconds: newDuration)
            newRecordState = .learn

        case .forget:
            newEase += referenceStatus.easeAdjustment
            newDuration = referenceStatus.forgetInterval
            newDueDate = learnedDate.adding(seconds: newDuration)
            newRecordState = userPressedStatusType == .easy ? .review : .relearn

        case .remember:
            newEase += referenceStatus.easeAdjustment
            newDuration = newEase * referenceStatus.easeBonus * (latestRecord == nil ? referenceStatus.firstPracticeInterval : latestRecord!.duration)
            newDueDate = learnedDate.adding(seconds: newDuration)
            newRecordState = userPressedStatusType == .again ? .relearn : .review

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
        newRecordState: PracticeRecordStandardStateType,
        referenceStatus: CDPracticeStatus
    ) {
        let standardRecord = CoreDataManager.shared.createEntity(ofType: CDPracticeRecordStandard.self)
        standardRecord.duration = newDuration
        standardRecord.status = referenceStatus
        standardRecord.learnedDate = learnedDate
        standardRecord.dueDate = newDueDate
        standardRecord.stateRawValue = newRecordState.rawValue.toInt64

        self.record?.addToStandardRecordSet(standardRecord)

        CoreDataManager.shared.save()
    }

    func getInterval(at order: Int, standardPreset: CDPracticePresetStandard) -> Double? {
        guard let statusType = PracticeStandardStatusType(rawValue: order) else { return nil }

        let referenceStatus = standardPreset.getStatus(from: statusType)

        guard let referenceStatus = referenceStatus else {
            return nil
        }

        let newValues = calculateNewValues(
            referenceStatus: referenceStatus,
            latestRecord: self.latestPracticeStandardRecord,
            userPressedStatusType: statusType,
            standardPreset: standardPreset
        )

        return newValues.newDuration
    }
}
