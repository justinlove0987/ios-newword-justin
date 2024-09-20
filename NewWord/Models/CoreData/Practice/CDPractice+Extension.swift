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
            guard let status = record.status,
                  let state = record.state
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

    var isLearning: Bool {
        guard !isNew else { return false }

        guard let latestState = latestPracticeStandardRecord?.state,
              let latestStatus = latestPracticeStandardRecord?.status else {
            return false
        }

        if (latestStatus.type == .again || latestStatus.type == .good || latestStatus.type == .hard) &&
            (latestState == .learn) {
            return true
        }

        return false
    }

    var isEasyTransition: Bool {
        guard let status = latestTransitionPracticeStandardRecord?.status else {
            return false
        }

        return status.type == .easy
    }

    var isAgainTransition: Bool {
        guard let status = latestTransitionPracticeStandardRecord?.status else {
            return false
        }

        return status.type == .again
    }

    var state: PracticeStandardState {
        if isNew {
            return .new
        }

        if isLearning {
            return .firstPractice
        }

        if isEasyTransition {
            return .easyTransition
        }
        

        if isAgainTransition {
            return .againTransition
        }

        return .unknown
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
            state: state,
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
        state: PracticeStandardState,
        referenceStatus: CDPracticeStatus,
        latestRecord: CDPracticeRecordStandard?,
        userPressedStatusType: PracticeStandardStatusType,
        standardPreset: CDPracticePresetStandard
    ) -> (Double, Double, Date, PracticeRecordStandardStateType) {

        var newEase: Double = latestRecord == nil ? standardPreset.firstPracticeEase : latestRecord!.ease
        var newDuration: Double = 0.0
        var newDueDate: Date = Date()
        var newRecordState: PracticeRecordStandardStateType = .relearn

        let learnedDate = Date() // 假設當前的日期為learnedDate

        switch state {
        case .new, .firstPractice:
            newEase = standardPreset.firstPracticeEase
            newDuration = referenceStatus.firstPracticeInterval
            newDueDate = learnedDate.adding(seconds: newDuration)
            newRecordState = .learn

        case .easyTransition:
            newEase += referenceStatus.easeAdjustment
            newDuration = newEase * referenceStatus.easeBonus * (latestRecord == nil ? referenceStatus.firstPracticeInterval : latestRecord!.duration)
            newDueDate = learnedDate.adding(seconds: newDuration)
            newRecordState = userPressedStatusType == .again ? .relearn : .review

        case .againTransition:
            newEase += referenceStatus.easeAdjustment
            newDuration = referenceStatus.forgetInterval
            newDueDate = learnedDate.adding(seconds: newDuration)
            newRecordState = userPressedStatusType == .easy ? .review : .relearn

        case .unknown:
            break
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

//    func getDuration(at order: Int) -> Double {
//        switch state {
//        case .new, .firstPractice:
//
//
//        case .easyTransition:
//            <#code#>
//        case .againTransition:
//            <#code#>
//        case .unknown:
//            <#code#>
//        }
//    }

}

// 針對整個record
enum PracticeStandardState: Int, CaseIterable {
    case new
    case firstPractice
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
