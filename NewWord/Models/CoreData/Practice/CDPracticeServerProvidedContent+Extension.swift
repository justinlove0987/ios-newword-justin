//
//  CDPracticeServerProvidedContent+CoreDataClass.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/9/30.
//
//

import Foundation
import CoreData

enum PracticeServerProvidedContentType: Int, CaseIterable {
    case article
}

@objc(CDPracticeServerProvidedContent)
public class CDPracticeServerProvidedContent: NSManagedObject {
    
    var type: PracticeServerProvidedContentType? {
        guard let type = PracticeServerProvidedContentType(rawValue: Int(typeRawValue)) else {
            return nil
        }
        
        return type
    }
}
