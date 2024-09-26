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

    var revisedRange: NSRange? {
        return NSRange(location: Int(revisedRangeLocation), length: Int(revisedRangeLength))
    }
    
    var userGeneratedContents: [CDPracticeUserGeneratedContent] {
        guard let contents = self.userGeneratedContentSet as? Set<CDPracticeUserGeneratedContent> else {
            return []
        }
        
        return Array(contents)
    }

    func isEqualTo(textType: ContextType, range: NSRange) -> Bool {
        return self.revisedRange == range &&
        self.type == type
    }

    func getTagIndex(in text: String) -> String.Index? {
        let location = revisedRange!.location - 1

        if let stringIndex = text.index(text.startIndex, offsetBy: location, limitedBy: text.endIndex) {
            return stringIndex
        }

        return nil
    }
}

// MARK: - Copy

extension CDUserGeneratedContextTag {
    struct Copy {
        var id: String?
        var number: Int64
        var originalRangeLength: Int64
        var originalRangeLocation: Int64
        var revisedRangeLength: Int64
        var revisedRangeLocation: Int64
        var tagColor: Data?
        var contentColor: Data?
        var text: String?
        var translation: String?
        var typeRawValue: Int64

        var range: NSRange? {
            return NSRange(location: Int(revisedRangeLocation), length: Int(revisedRangeLength))
        }
    }

    func copy() -> Copy {
        return Copy(id: id,
                    number: number,
                    originalRangeLength: originalRangeLength,
                    originalRangeLocation: originalRangeLocation,
                    revisedRangeLength: revisedRangeLength,
                    revisedRangeLocation: revisedRangeLocation,
                    tagColor: tagColor,
                    contentColor: tagContentColor,
                    text: text,
                    translation: translation,
                    typeRawValue: typeRawValue )
    }
}
