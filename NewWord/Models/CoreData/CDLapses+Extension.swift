//
//  CDLapses+Extension.swift
//  NewWord
//
//  Created by justin on 2024/5/31.
//

import Foundation
import CoreData

@objc(CDLapses)
public class CDLapses: NSManagedObject {

}


extension CDLapses {
    enum LeachAction {
        case tagOnly
        case suspendCard
        case moveToStrengthenArea
    }

    var leachAction: LeachAction {
        switch leachActionRawValue {
        case 0:
            return .tagOnly
        case 1:
            return .suspendCard
        case 2:
            return .moveToStrengthenArea
        default:
            return .moveToStrengthenArea
        }
    }

}
