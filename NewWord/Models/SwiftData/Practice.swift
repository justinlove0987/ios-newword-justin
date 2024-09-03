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

    var type: Int
    var resource: PracticeResource?
    var preset: PracticePreset?
    var records: [PracticeRecord] = []

    init(type: Int, 
         preset: PracticePreset,
         resource: PracticeResource,
         records: [PracticeRecord] = []) {
        
        self.type = type
        self.preset = preset
        self.resource = resource
        self.records = records
    }
    
    private enum CodingKeys: String, CodingKey {
        case type
        case resource
        case preset
        case records
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.type = try container.decode(Int.self, forKey: .type)
        self.resource = try container.decodeIfPresent(PracticeResource.self, forKey: .resource) ?? nil
        self.preset = try container.decodeIfPresent(PracticePreset.self, forKey: .preset) ?? nil
        self.records = try container.decode([PracticeRecord].self, forKey: .records)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encodeIfPresent(resource, forKey: .resource)
        try container.encodeIfPresent(preset, forKey: .preset)
        try container.encode(records, forKey: .records)
    }
}
