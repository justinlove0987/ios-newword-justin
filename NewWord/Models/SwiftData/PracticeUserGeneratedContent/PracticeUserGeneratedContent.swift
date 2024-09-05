//
//  PracticeUserGeneratedData.swift
//  NewWord
//
//  Created by justin on 2024/9/3.
//

import SwiftData
import UIKit


@Model
class PracticeUserGeneratedContent: Identifiable, Codable {
    
    // MARK: - Properties
    
    var id: String?

    // MARK: - Initializer
    init(id: String? = nil) {
        self.id = id
    }

    // MARK: - Codable Keys
    private enum CodingKeys: String, CodingKey {
        case id
    }

    // MARK: - Codable Methods
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
    }
}

extension PracticeUserGeneratedContent {
    
    class Copy {
        
    }
    
}
