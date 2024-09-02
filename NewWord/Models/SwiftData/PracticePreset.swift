//
//  PracticePreset.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/9/2.
//

import UIKit
import SwiftData

@Model
class PracticePreset: Codable {
    
    init() {}
    
    var defaultPreset: DefaultPracticePreset?
    
    private enum CodingKeys: String, CodingKey {
        case defaultPreset
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.defaultPreset = try container.decode(DefaultPracticePreset.self, forKey: .defaultPreset)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(defaultPreset, forKey: .defaultPreset)
    }
}
