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
    
    var stortedStandardRecords: [CDPracticeRecordStandard] {
        standardRecords.sorted { lRecord, rRecord in
            guard let lDate = lRecord.learnedDate,
                  let rDate = rRecord.learnedDate else {
                return false
            }
            
            return lDate < rDate
        }
    }
    
    var totalEasyAttempts: Int {
        return standardRecords.filter { $0.statusType == .easy }.count
    }
    
    var totalAgainAttempts: Int {
        return standardRecords.filter { $0.statusType == .again }.count
    }
    
    var cumulativeEasyAttempts: Int {
        
        var maxCumulativeEasyAttempts: Int = 0
        var cumulativeEasyAttempts: Int = 0
        
        for record in stortedStandardRecords {
            if record.statusType == .easy {
                cumulativeEasyAttempts += 1
            } else {
                maxCumulativeEasyAttempts = max(maxCumulativeEasyAttempts, cumulativeEasyAttempts)
                cumulativeEasyAttempts = 0
            }
        }
        
        return maxCumulativeEasyAttempts
    }
    
    var cumulativeAgainAttempts: Int {
        
        var maxCumulativeEasyAttempts: Int = 0
        var cumulativeEasyAttempts: Int = 0
        
        for record in stortedStandardRecords {
            if record.statusType == .again {
                cumulativeEasyAttempts += 1
            } else {
                maxCumulativeEasyAttempts = max(maxCumulativeEasyAttempts, cumulativeEasyAttempts)
                cumulativeEasyAttempts = 0
            }
        }
        
        return maxCumulativeEasyAttempts
    }
}


enum PracticeRecordType: Int, CaseIterable {
    case standard
}
