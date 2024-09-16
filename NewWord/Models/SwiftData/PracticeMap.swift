//
//  PracticeMap.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/8/29.
//

import UIKit
import SwiftData



@Model
class PracticeMap: Identifiable, Codable {
    // MARK: - Properties

    var id: String?
    var type: Int
    var sequences: [PracticeSequence] = []

    // MARK: - Initializer

    init(id: String? = nil,
         type: Int,
         sequences: [PracticeSequence]) {
        
        self.id = id
        self.type = type
        self.sequences = sequences
    }

    // MARK: - Codable Keys
    
    private enum CodingKeys: String, CodingKey {
        case id
        case type
        case sequences
    }

    // MARK: - Codable Methods
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        type = try container.decode(Int.self, forKey: .type)
        sequences = try container.decode([PracticeSequence].self, forKey: .sequences)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(type, forKey: .type)
        try container.encode(sequences, forKey: .sequences)
    }
}
