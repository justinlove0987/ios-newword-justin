//
//  CDNote+CoreDataClass.swift
//  
//
//  Created by 曾柏楊 on 2024/7/28.
//
//

import Foundation
import CoreData

enum NoteType: Int {
    case sentenceCloze
    case prononciation
    case cloze
    case lienteningCloze
}

@objc(CDNote)
public class CDNote: NSManagedObject {

}

extension CDNote {
    
    var type: NoteType? {
        guard let type = NoteType(rawValue: Int(typeRawValue)) else {
            return nil
        }
        
        return type
    }
    
    enum Resource {
        case cloze(CDCloze)
        case sentenceCloze(CDSentenceCloze)
    }
    
    var wrappedResource: Resource? {
        guard let resource else { return  nil }
        
        switch type {
        case .sentenceCloze:
            return .sentenceCloze(resource.sentenceCloze!)
            
        case .cloze, .lienteningCloze:
            return .cloze(resource.cloze!)
            
        default:
            return nil
        }
    }
}
