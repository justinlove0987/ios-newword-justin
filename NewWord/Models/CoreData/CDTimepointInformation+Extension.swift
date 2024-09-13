//
//  CDTimepointInformation+CoreDataProperties.swift
//  NewWord
//
//  Created by justin on 2024/9/13.
//
//

import Foundation
import CoreData

@objc(CDTimepointInformation)
public class CDTimepointInformation: NSManagedObject {

}

extension CDTimepointInformation {
    var range: NSRange? {
        return NSRange(location: Int(rangeLocation), length: Int(rangeLength))
    }
}
