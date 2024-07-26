//
//  CDNoteType+Extensions.swift
//  NewWord
//
//  Created by justin on 2024/5/31.
//

import Foundation
import CoreData

enum NoteType: Int {
    case sentenceCloze
    case prononciation
    case cloze
    case lienteningCloze
}

@objc(CDNoteType)
public class CDNoteType: NSManagedObject {

}

extension CDNoteType {
    
    enum Resource {
        case cloze(CDCloze)
        case sentenceCloze(CDSentenceCloze)
    }
    
    var type: NoteType? {
        guard let type = NoteType(rawValue: Int(rawValue)) else {
            return nil
        }
        
        return type
    }
    
    var resource: Resource? {
        switch type {
        case .sentenceCloze:
            return .sentenceCloze(sentenceCloze!)
        case .cloze, .lienteningCloze:
            return .cloze(cloze!)
        default:
            return nil
        }
    }
    
}
