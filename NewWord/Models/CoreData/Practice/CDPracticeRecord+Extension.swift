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
    
    var standardRecords: [CDPracticeRecordStandard] {
        guard let recordSet = self.standardRecordSet as? Set<CDPracticeRecordStandard> else {
            return []
        }
        
        return Array(recordSet)
    }
}


enum PracticeRecordType: Int, CaseIterable {
    case standard
}
