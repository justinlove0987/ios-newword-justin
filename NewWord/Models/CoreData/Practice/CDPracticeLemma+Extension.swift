//
//  CDPracticeLemmaContext+CoreDataClass.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/10/4.
//
//

import Foundation
import CoreData

@objc(CDPracticeLemma)
public class CDPracticeLemma: NSManagedObject {

}

extension CDPracticeLemma {
    var contexts: [CDPracticeContext] {
        guard let contexts = self.contextSet as? Set<CDPracticeContext> else {
            return []
        }
        
        return Array(contexts)
    }
    
    var hasContext: Bool {
        return contexts.count > 0
    }
}
