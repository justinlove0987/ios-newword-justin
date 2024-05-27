//
//  CDNoteType+CoreDataProperties.swift
//  NewWord
//
//  Created by justin on 2024/5/27.
//
//

import Foundation
import CoreData


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
