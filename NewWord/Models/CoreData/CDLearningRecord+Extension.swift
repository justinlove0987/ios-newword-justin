//
//  CDLearningRecord+Extension.swift
//  NewWord
//
//  Created by justin on 2024/5/31.
//

import Foundation
import CoreData

@objc(CDLearningRecord)
public class CDLearningRecord: NSManagedObject {

}

extension CDLearningRecord {
    enum State: String, Codable {
        case learn
        case review
        case relearn
        case leach
        case master

        enum CodingKeys: String, CodingKey {
            case learn
            case review
            case relearn
            case leach
            case master
        }
    }

    enum Status: String, Codable {
        case correct
        case incorrect

        enum CodingKeys: String, CodingKey {
            case correct
            case incorrect
        }
    }

    var state: State {
        return State(rawValue: stateRawValue!)!
    }

    var status: Status {
        return Status(rawValue: statusRawValue!)!
    }
    
    /// The unit of interval is **second**.
    var interval: Double {
        return dueDate!.timeIntervalSince(learnedDate!) // seconds
    }
}

