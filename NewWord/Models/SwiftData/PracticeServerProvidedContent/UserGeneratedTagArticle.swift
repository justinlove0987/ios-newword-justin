//
//  UserGeneratedTagArticle.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/9/12.
//

import UIKit
import SwiftData


@Model
class UserGeneratedTagArticle: Identifiable, Codable {

    // MARK: - Properties

    var id: String
    var tags: [ContextTag] = []
    var revisedTags: [ContextTag] = []
    var revisedText: String?
    var revisedTimepoints: [TimepointInformation] = []

    // MARK: - Initializer

    init(id: String,
         tags: [ContextTag] = [],
         revisedTags: [ContextTag] = [],
         revisedText: String? = nil,
         revisedTimepoints: [TimepointInformation] = []
    ) {
        self.id = id
        self.tags = tags
        self.revisedTags = revisedTags
        self.revisedText = revisedText
        self.revisedTimepoints = revisedTimepoints
    }

    // MARK: - Codable Keys

    private enum CodingKeys: String, CodingKey {
        case id
        case tags
        case revisedTags
        case revisedText
        case revisedTimepoints
    }

    // MARK: - Codable Methods

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.tags = try container.decodeIfPresent([ContextTag].self, forKey: .tags) ?? []
        self.revisedTags = try container.decodeIfPresent([ContextTag].self, forKey: .revisedTags) ?? []
        self.revisedText = try container.decodeIfPresent(String.self, forKey: .revisedText)
        self.revisedTimepoints = try container.decodeIfPresent([TimepointInformation].self, forKey: .revisedTimepoints) ?? []
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(tags, forKey: .tags)
        try container.encodeIfPresent(revisedTags, forKey: .revisedTags)
        try container.encodeIfPresent(revisedText, forKey: .revisedText)
        try container.encodeIfPresent(revisedTimepoints, forKey: .revisedTimepoints)
    }
}

extension UserGeneratedTagArticle {

    class Copy: Identifiable, Hashable {
        var id: String
        var tags: [ContextTag.Copy] = []
        var revisedTags: [ContextTag.Copy] = []
        var revisedText: String?
        var revisedTimepoints: [TimepointInformation.Copy] = []

        init(id: String,
             tags: [ContextTag.Copy] = [],
             revisedTags: [ContextTag.Copy] = [],
             revisedText: String? = nil,
             revisedTimepoints: [TimepointInformation.Copy] = []
        ) {
            self.id = id
            self.tags = tags
            self.revisedTags = revisedTags
            self.revisedText = revisedText
            self.revisedTimepoints = revisedTimepoints
        }

        static func == (lhs: Copy, rhs: Copy) -> Bool {
            return lhs.id == rhs.id
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }

    func copy() -> Copy {
        let copy = Copy(
            id: self.id,
            tags: self.tags.map { $0.copy() },
            revisedTags: self.revisedTags.map { $0.copy() },
            revisedText: self.revisedText,
            revisedTimepoints: self.revisedTimepoints.map { $0.copy() }
        )
        return copy
    }

    static func copyArticles(from articles: [UserGeneratedTagArticle]) -> [Copy] {
        return articles.map { $0.copy() }
    }
}
