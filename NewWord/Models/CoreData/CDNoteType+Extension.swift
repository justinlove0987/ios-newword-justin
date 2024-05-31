//
//  CDNoteType+Extensions.swift
//  NewWord
//
//  Created by justin on 2024/5/31.
//

import Foundation
import CoreData

@objc(CDNoteType)
public class CDNoteType: NSManagedObject {

}

extension CDNoteType {
    enum Content {
        case sentenceCloze(CDSentenceCloze)
        case prononciation

        enum CodingKeys: String, CodingKey {
            case sentenceCloze
            case prononciation
        }
    }

    var content: Content? {
        switch rawValue {
        case 0:
            return .sentenceCloze(sentenceCloze!)
        default:
            return nil
        }
    }

}
