//
//  Practice.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/9/2.
//

import UIKit
import SwiftData

@Model
class Practice: Identifiable, Codable {
    // MARK: - Properties
    var id: UUID // Identifiable 需要的 id 屬性
    var type: Int
    var resource: PracticeResource?
    var ugc: PracticeUserGeneratedContent?
    var preset: PracticePreset?
    var records: [PracticeRecord] = []

    // MARK: - Initializer
    init(id: UUID = UUID(),
         type: Int,
         preset: PracticePreset,
         resource: PracticeResource,
         ugc: PracticeUserGeneratedContent? = nil,
         records: [PracticeRecord] = []) {

        self.id = id
        self.type = type
        self.preset = preset
        self.resource = resource
        self.ugc = ugc
        self.records = records
    }

    // MARK: - Codable Keys
    private enum CodingKeys: String, CodingKey {
        case id
        case type
        case resource
        case ugc
        case preset
        case records
    }

    // MARK: - Codable Methods
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        type = try container.decode(Int.self, forKey: .type)
        resource = try container.decodeIfPresent(PracticeResource.self, forKey: .resource)
        ugc = try container.decodeIfPresent(PracticeUserGeneratedContent.self, forKey: .ugc)
        preset = try container.decodeIfPresent(PracticePreset.self, forKey: .preset)
        records = try container.decode([PracticeRecord].self, forKey: .records)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(type, forKey: .type)
        try container.encodeIfPresent(resource, forKey: .resource)
        try container.encodeIfPresent(ugc, forKey: .ugc)
        try container.encodeIfPresent(preset, forKey: .preset)
        try container.encode(records, forKey: .records)
    }
}
