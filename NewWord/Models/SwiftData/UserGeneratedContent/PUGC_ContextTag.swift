//
//  PracticeTag.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/9/4.
//


import UIKit
import SwiftData


@Model
class PUGC_ContextTag: Identifiable, Codable {
    // MARK: - Properties
    var id: String?
    var rangeLocation: Int?
    var rangelength: Int?
    var number: Int?
    var translation: String?
    var contextId: String?
    

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
