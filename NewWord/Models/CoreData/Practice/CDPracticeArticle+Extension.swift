//
//  CDPracticeArticle+CoreDataProperties.swift
//  NewWord
//
//  Created by justin on 2024/9/13.
//
//

import Foundation
import CoreData

enum CEFR: Int, CaseIterable, Codable {
    case none = -1
    case a1 = 0
    case a2
    case b1
    case b2
    case c1
    case c2

    var title: String {
        switch self {
        case .none:
            return "未分類"
        case .a1:
            return "A1"
        case .a2:
            return "A2"
        case .b1:
            return "B1"
        case .b2:
            return "B2"
        case .c1:
            return "C1"
        case .c2:
            return "C2"
        }
    }
}

@objc(CDPracticeArticle)
public class CDPracticeArticle: NSManagedObject {

}

extension CDPracticeArticle {
    
    var timepoints: [CDTimepointInformation] {
        guard let timepointSet = self.timepointSet as? Set<CDTimepointInformation> else {
            return []
        }
        
        
        return Array(timepointSet)
    }

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
    
    func createText() -> String? {
        guard let title,
              let content else {
            return nil
        }
        
        return "\(title)\n\n\(content)"
    }

}

