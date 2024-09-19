//
//  CDPracticePresetStandard+CoreDataClass.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/9/19.
//
//

import Foundation
import CoreData

@objc(CDPracticePresetStandard)
public class CDPracticePresetStandard: NSManagedObject {

}

extension CDPracticePresetStandard {
    var statuses: [CDPracticeStatus] {
        guard let statusSet = self.statusSet as? Set<CDPracticeStatus> else {
            return []
        }
        
        return Array(statusSet)
    }
    
    func getStatus(from userPressedStatus: PracticeStandardStatusType) -> CDPracticeStatus? {
        for status in statuses {
            if status.type == userPressedStatus {
                return status
            }
        }
        
        return nil
    }
}
