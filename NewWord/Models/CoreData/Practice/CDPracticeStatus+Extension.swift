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
    var type: PracticeStatusType {
        return PracticeStatusType(rawValue: Int(typeRawValue))
    }
}

enum PracticeStatusType: Int, CaseIterable {
    
}
