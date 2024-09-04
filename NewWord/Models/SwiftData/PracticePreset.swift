//
//  PracticePreset.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/9/2.
//

import UIKit
import SwiftData

@Model
class PracticePreset: Identifiable, Codable {

    // MARK: - Properties

    var id: String?
    var defaultPreset: DefaultPracticePreset?

    // MARK: - Initializers

    init() {}

    init(defaultPreset: DefaultPracticePreset? = nil) {
        self.defaultPreset = defaultPreset
    }

    // MARK: - Codable Keys

    private enum CodingKeys: String, CodingKey {
        case id
        case defaultPreset
    }

    // MARK: - Codable Methods
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.defaultPreset = try container.decodeIfPresent(DefaultPracticePreset.self, forKey: .defaultPreset)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(defaultPreset, forKey: .defaultPreset)
    }
}
