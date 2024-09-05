//
//  PracticeRecord.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/9/2.
//

import UIKit
import SwiftData

@Model
class PracticeRecord: Identifiable, Codable {

    var id: String?
    var defaultRecord: DefaultPracticeRecord?

    init() {}

    private enum CodingKeys: String, CodingKey {
        case defaultRecord
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.defaultRecord = try container.decode(DefaultPracticeRecord.self, forKey: .defaultRecord)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(defaultRecord, forKey: .defaultRecord)
    }
}
