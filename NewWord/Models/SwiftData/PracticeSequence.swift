//
//  PracticeSequence.swift
//  NewWord
//
//  Created by justin on 2024/9/3.
//

import UIKit
import SwiftData


@Model
class PracticeSequence: Identifiable, Codable {
    // MARK: - Properties
    var id: UUID 
    var practices: [Practice] = []

    // MARK: - Initializer
    init(id: UUID = UUID(), practices: [Practice]) {
        self.id = id
        self.practices = practices
    }

    // MARK: - Codable Keys
    private enum CodingKeys: String, CodingKey {
        case id
        case practices
    }

    // MARK: - Codable Methods
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        practices = try container.decode([Practice].self, forKey: .practices)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(practices, forKey: .practices)
    }
}
