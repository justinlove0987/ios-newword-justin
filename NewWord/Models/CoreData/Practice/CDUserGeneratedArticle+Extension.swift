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
    var userGeneratedContextTags: [CDUserGeneratedContextTag] {
        guard let tags = self.userGeneratedContextTags as? Set<CDUserGeneratedContextTag> else {
            return []
        }
        
        return tags
    }
}
