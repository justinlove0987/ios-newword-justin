//
//  CDPracticeArticle+CoreDataProperties.swift
//  NewWord
//
//  Created by justin on 2024/9/13.
//
//

import Foundation
import CoreData

@objc(CDPracticeArticle)
public class CDPracticeArticle: NSManagedObject {

}

extension CDPracticeArticle {

    var formattedUploadedDate: String? {
        guard let uploadedDate else { return nil }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        return dateFormatter.string(from: uploadedDate)
    }

    var hasAudio: Bool {
        return audioResource?.data != nil
    }

    var hasImage: Bool {
        return imageResource?.data != nil
    }

    var cefr: CEFR? {
        return CEFR(rawValue: Int(cefrRawValue))
    }

}

