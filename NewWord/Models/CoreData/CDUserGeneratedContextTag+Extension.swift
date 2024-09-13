//
//  CDUserGeneratedContextTag+CoreDataProperties.swift
//  NewWord
//
//  Created by justin on 2024/9/13.
//
//

import Foundation
import CoreData

@objc(CDUserGeneratedContextTag)
public class CDUserGeneratedContextTag: NSManagedObject {

}


extension CDUserGeneratedContextTag {
    var type: ContextType? {
        return ContextType(rawValue: Int(typeRawValue))
    }

    var range: NSRange? {
        return NSRange(location: Int(revisedRangeLocation), length: Int(revisedRangeLength))
    }

    func isEqualTo(_ other: ContextTag.Copy) -> Bool {
        return self.range == other.range &&
        self.type == other.type
    }

    func isEqualTo(textType: ContextType, range: NSRange) -> Bool {
        return self.range == range &&
        self.type == type
    }

    func getTagIndex(in text: String) -> String.Index? {
        let location = range!.location - 1

        if let stringIndex = text.index(text.startIndex, offsetBy: location, limitedBy: text.endIndex) {
            return stringIndex
        }

        return nil
    }


}
