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
    var type: PracticeStatusStandardType? {
        return PracticeStatusStandardType(rawValue: Int(typeRawValue))
    }
}

enum PracticeStatusStandardType: Int, CaseIterable {
    case again
    case hard
    case good
    case easy
}
