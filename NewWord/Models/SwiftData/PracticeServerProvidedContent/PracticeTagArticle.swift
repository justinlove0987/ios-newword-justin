//
//  Article.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/9/2.
//


import UIKit
import SwiftData


@Model
class PracticeTagArticle: Identifiable, Codable {
    
    var id: String
    var title: String?
    var content: String?
    var text: String?
    var uploadedDate: Date?
    var audioResource: PracticeAudio?
    var imageResource: PracticeImage?
    var cefrType: Int?
    var tags: [ContextTag] = []
    var revisedTags: [ContextTag] = []
    var revisedText: String?
    var revisedTimepoints: [TimepointInformation] = []

    // 初始化方法
    init(id: String,
         title: String? = nil,
         content: String? = nil,
         text: String? = nil,
         uploadedDate: Date? = nil,
         audioResource: PracticeAudio? = nil,
         imageResource: PracticeImage? = nil,
         cefrType: Int? = nil,
         tags: [ContextTag] = [],
         revisedTags: [ContextTag] = [],
         revisedText: String? = nil,
         revisedTimepoints: [TimepointInformation] = []
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.text = text
        self.uploadedDate = uploadedDate
        self.audioResource = audioResource
        self.imageResource = imageResource
        self.cefrType = cefrType
        self.tags = tags
        self.revisedTags = revisedTags
        self.revisedText = revisedText
        self.revisedTimepoints = revisedTimepoints
    }
    
    // CodingKeys 枚舉，用於定義屬性與 JSON 鍵的對應
    private enum CodingKeys: String, CodingKey {
        case id
        case title
        case content
        case text
        case uploadedDate
        case audioResource
        case imageResource
        case cefrType
        case tags
        case revisedText
        case revisedTags
        case revisedTimepoints
    }
    
    // 解碼方法
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.title = try container.decodeIfPresent(String.self, forKey: .title)
        self.text = try container.decodeIfPresent(String.self, forKey: .text)
        self.content = try container.decodeIfPresent(String.self, forKey: .content)
        self.uploadedDate = try container.decodeIfPresent(Date.self, forKey: .uploadedDate)
        self.audioResource = try container.decodeIfPresent(PracticeAudio.self, forKey: .audioResource)
        self.imageResource = try container.decodeIfPresent(PracticeImage.self, forKey: .imageResource)
        self.cefrType = try container.decodeIfPresent(Int.self, forKey: .cefrType)
        self.revisedText = try container.decode(String.self, forKey: .revisedText)
        self.revisedTags = try container.decode([ContextTag].self, forKey: .revisedTags)
        self.revisedTimepoints = try container.decode([TimepointInformation].self, forKey: .revisedTimepoints)
    }
    
    // 編碼方法
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(title, forKey: .title)
        try container.encodeIfPresent(content, forKey: .content)
        try container.encodeIfPresent(content, forKey: .text)
        try container.encodeIfPresent(uploadedDate, forKey: .uploadedDate)
        try container.encodeIfPresent(audioResource, forKey: .audioResource)
        try container.encodeIfPresent(imageResource, forKey: .imageResource)
        try container.encodeIfPresent(cefrType, forKey: .cefrType)
        try container.encodeIfPresent(revisedTags, forKey: .revisedTags)
        try container.encodeIfPresent(revisedText, forKey: .revisedText)
        try container.encodeIfPresent(revisedTimepoints, forKey: .revisedTimepoints)
    }
}

extension PracticeTagArticle {

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
        guard let cefrType else { return nil }
        return CEFR(rawValue: cefrType)
    }
}


extension PracticeTagArticle {

    class Copy: Identifiable, Hashable {
        var id: String
        var title: String?
        var content: String?
        var text: String?
        var uploadedDate: Date?
        var audioResource: PracticeAudio.Copy?
        var imageResource: PracticeImage.Copy?
        var cefrType: Int?
        var tags: [ContextTag.Copy] = []
        var revisedTags: [ContextTag.Copy] = []
        var revisedText: String?
        var revisedTimepoints: [TimepointInformation.Copy] = []

        init(id: String,
             title: String? = nil,
             content: String? = nil,
             text: String? = nil,
             uploadedDate: Date? = nil,
             audioResource: PracticeAudio.Copy? = nil,
             imageResource: PracticeImage.Copy? = nil,
             cefrType: Int? = nil,
             tags: [ContextTag.Copy] = [],
             revisedTags: [ContextTag.Copy] = [],
             revisedText: String? = nil,
             revisedTimepoints: [TimepointInformation.Copy] = []

        ) {
            self.id = id
            self.title = title
            self.content = content
            self.text = text
            self.uploadedDate = uploadedDate
            self.audioResource = audioResource
            self.imageResource = imageResource
            self.cefrType = cefrType
            self.tags = tags
            self.revisedTags = revisedTags
            self.revisedText = revisedText
            self.revisedTimepoints = revisedTimepoints

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
            guard let cefrType else { return nil }
            return CEFR(rawValue: cefrType)
        }

        static func == (lhs: Copy, rhs: Copy) -> Bool {
            return lhs.id == rhs.id
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }
    

    func copy() -> Copy {
        
        let hasNoText = self.text == nil && self.title != nil && self.content != nil
        let hasNoRevisedText = self.revisedText == nil && self.title != nil && self.content != nil
        let text = hasNoText ? "\(self.title!)\n\n\(self.content!)" : self.text
        let revisedText = hasNoRevisedText ? "\(self.title!)\n\n\(self.content!)" : self.revisedText
        let revisedTimpoints = (self.revisedTimepoints.isEmpty ? self.audioResource?.timepoints.map { $0.copy() } : self.revisedTimepoints.map { $0.copy() }) ?? []

        let copy = Copy(
            id: self.id,
            title: self.title,
            content: self.content,
            text: text,
            uploadedDate: self.uploadedDate,
            audioResource: self.audioResource?.copy(),
            imageResource: self.imageResource?.copy(),
            cefrType: self.cefrType,
            tags: self.tags.map { $0.copy() },
            revisedTags: self.revisedTags.map { $0.copy() },
            revisedText: revisedText,
            revisedTimepoints: revisedTimpoints
        )
        
        return copy
    }

    static func copyArticles(from articles: [PracticeTagArticle]) -> [Copy] {
        return articles.map { $0.copy() }
    }
}
