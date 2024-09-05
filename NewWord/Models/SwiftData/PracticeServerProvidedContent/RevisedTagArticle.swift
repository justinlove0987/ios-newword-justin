//
//  RevisedArticle.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/9/5.
//

import UIKit
import SwiftData

@Model
class RevisedTagArticle: Identifiable, Codable {
    var id: String
    var revisedTitle: String?  // 更新過的標題
    var revisedContent: String?  // 更新過的內容
    var tags: [ContextTag] = []  // 更新過的標籤
    var updatedTimepoints: [TimepointInformation] = []  // 更新過的時間點

    // 初始化方法
    init(id: String,
         revisedTitle: String? = nil,
         revisedContent: String? = nil,
         tags: [ContextTag] = [],
         updatedTimepoints: [TimepointInformation] = []
    ) {
        self.id = id
        self.revisedTitle = revisedTitle
        self.revisedContent = revisedContent
        self.tags = tags
        self.updatedTimepoints = updatedTimepoints
    }

    // CodingKeys 枚舉，用於定義屬性與 JSON 鍵的對應
    private enum CodingKeys: String, CodingKey {
        case id
        case revisedTitle
        case revisedContent
        case tags
        case updatedTimepoints
    }

    // 解碼方法
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.revisedTitle = try container.decodeIfPresent(String.self, forKey: .revisedTitle)
        self.revisedContent = try container.decodeIfPresent(String.self, forKey: .revisedContent)
        self.tags = try container.decode([ContextTag].self, forKey: .tags)
        self.updatedTimepoints = try container.decode([TimepointInformation].self, forKey: .updatedTimepoints)
    }

    // 編碼方法
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(revisedTitle, forKey: .revisedTitle)
        try container.encodeIfPresent(revisedContent, forKey: .revisedContent)
        try container.encode(tags, forKey: .tags)
        try container.encode(updatedTimepoints, forKey: .updatedTimepoints)
    }
}

extension RevisedTagArticle {

    class Copy: Identifiable, Hashable {
        var id: String
        var revisedTitle: String?
        var revisedContent: String?
        var tags: [ContextTag.Copy] = []
        var updatedTimepoints: [TimepointInformation.Copy] = []

        init(id: String,
             revisedTitle: String? = nil,
             revisedContent: String? = nil,
             tags: [ContextTag.Copy] = [],
             updatedTimepoints: [TimepointInformation.Copy] = []
        ) {
            self.id = id
            self.revisedTitle = revisedTitle
            self.revisedContent = revisedContent
            self.tags = tags
            self.updatedTimepoints = updatedTimepoints
        }

        var text: String? {
            guard let revisedTitle, let revisedContent else { return nil }
            return "\(revisedTitle)\n\n\(revisedContent)"
        }

        static func == (lhs: Copy, rhs: Copy) -> Bool {
            return lhs.id == rhs.id
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }

    func copy() -> Copy {
        return Copy(
            id: self.id,
            revisedTitle: self.revisedTitle,
            revisedContent: self.revisedContent,
            tags: self.tags.map { $0.copy() },
            updatedTimepoints: self.updatedTimepoints.map { $0.copy() }
        )
    }
}
