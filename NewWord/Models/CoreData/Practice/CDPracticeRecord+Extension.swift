//
//  CDPracticeRecord+CoreDataClass.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/9/17.
//
//

import Foundation
import CoreData

@objc(CDPracticeRecord)
public class CDPracticeRecord: NSManagedObject {

}

extension CDPracticeRecord {
    
    var type: PracticeRecordType? {
        return PracticeRecordType(rawValue: Int(typeRawValue))
    }
    
    var standardArray: [CDPracticeRecordStandard] {
        guard let records = self.standards as? Set<CDPracticeRecordStandard> else {
            return []
        }
        
        return Array(records)
    }
}


enum PracticeRecordType: Int, CaseIterable {
    case standard
}
