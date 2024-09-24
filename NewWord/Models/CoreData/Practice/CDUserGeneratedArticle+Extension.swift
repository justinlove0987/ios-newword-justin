//
//  CDUserGeneratedArticle+CoreDataClass.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/9/23.
//
//

import Foundation
import CoreData

@objc(CDUserGeneratedArticle)
public class CDUserGeneratedArticle: NSManagedObject {

}

extension CDUserGeneratedArticle {
    
    var contexts: [CDUserGeneratedContextTag] {
        guard let contexts = self.userGeneratedContextTagSet as? Set<CDUserGeneratedContextTag> else {
            return []
        }
        
        let sortedContexts = Array(contexts).sorted { $0.revisedRangeLocation < $1.revisedRangeLocation }
        
        return sortedContexts
    }
    
    
    var sortedTaggedContext: [CDUserGeneratedContextTag] {
        guard let contexts = self.userGeneratedContextTagSet as? Set<CDUserGeneratedContextTag> else {
            return []
        }
        
        let taggedContexts = Array(contexts).filter { $0.isTag }
        
        let sortedTaggedContexts = taggedContexts.sorted { $0.revisedRangeLocation < $1.revisedRangeLocation }
        
        return sortedTaggedContexts
    }
    
//    var userGeneratedContextTags: [CDUserGeneratedContextTag] {
//        guard let tags = self.userGeneratedContextTagSet as? Set<CDUserGeneratedContextTag> else {
//            return []
//        }
//        
//        var sortedTags = tags.filter { $0.isTag }
//        
//        sortedTags = tags.sorted { $0.revisedRangeLocation < $1.revisedRangeLocation }
//        
//        return Array(sortedTags)
//    }
}
