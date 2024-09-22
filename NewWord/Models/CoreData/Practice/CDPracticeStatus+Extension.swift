//
//  CDPracticeStatus+CoreDataClass.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/9/17.
//
//

import Foundation
import CoreData

@objc(CDPracticeStatus)
public class CDPracticeStatus: NSManagedObject {

}

extension CDPracticeStatus {
    var type: PracticeStandardStatusType? {
        return PracticeStandardStatusType(rawValue: Int(typeRawValue))
    }
}

extension CDPracticeStatus {
    func copy() -> CDPracticeStatus {
        let copy = CoreDataManager.shared.createEntity(ofType: CDPracticeStatus.self)

        copy.easeAdjustment = self.easeAdjustment
        copy.easeBonus = self.easeBonus
        copy.firstPracticeInterval = self.firstPracticeInterval
        copy.forgetInterval = self.forgetInterval
        copy.order = self.order
        copy.title = self.title
        copy.typeRawValue = self.typeRawValue

        return copy
    }
}

enum PracticeStandardStatusType: Int, CaseIterable {
    case again
    case hard
    case good
    case easy
    
    var title: String {
        switch self {
        case .again:
            return "再一次"
        case .hard:
            return "困難"
        case .good:
            return "良好"
        case .easy:
            return "簡單"
        }
    }
    
    var easeBonus: Double {
        switch self {
        case .easy:
            return 1.3
        default:
            return 1
        }
    }
    
    var easeAdjustment: Double {
        switch self {
        case .easy:
            return 0.2
        default:
            return 0.0
        }
    }
    
    var firstPracticeInterval: Double {
        let timeConverter = TimeConverter()
        
        switch self {
        case .again:
            return 1
        case .hard:
            return 15
        case .good:
            return timeConverter.convertToSeconds(from: .minutes(10))
        case .easy:
            return timeConverter.convertToSeconds(from: .days(3))
        }
    }
    
    var forgetInterval: Double {
        let timeConverter = TimeConverter()
        
        switch self {
        case .again:
            return 1
        case .hard:
            return timeConverter.convertToSeconds(from: .minutes(1))
        case .good:
            return timeConverter.convertToSeconds(from: .minutes(10))
        case .easy:
            return timeConverter.convertToSeconds(from: .days(3))
        }
    }
    
    var order: Int {
        return self.rawValue
    }
}
