//
//  Image.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/9/2.
//

import UIKit
import SwiftData


@Model
class PracticeImage: Identifiable, Codable {

    // MARK: - Properties

    var id: String?
    var data: Data?

    // MARK: - Initializer

    init(id: String? = nil, data: Data? = nil) {
        self.id = id
        self.data = data
    }

    // MARK: - Codable Keys

    private enum CodingKeys: String, CodingKey {
        case id
        case data
    }

    // MARK: - Codable Methods

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.data = try container.decode(Data.self, forKey: .data)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(data, forKey: .data)
    }
}

extension PracticeImage {

    // MARK: - Computed Property

    var image: UIImage? {
        guard let data else { return nil }
        return UIImage(data: data)
    }
}

extension PracticeImage {

    class Copy: Identifiable, Hashable {
        
        var id: String?
        var data: Data?

        init(id: String? = nil,
             data: Data? = nil) {
            
            self.id = id
            self.data = data
        }

        var image: UIImage? {
            guard let data else { return nil }
            return UIImage(data: data)
        }

        static func == (lhs: Copy, rhs: Copy) -> Bool {
            return lhs.id == rhs.id
        }


        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }
}

