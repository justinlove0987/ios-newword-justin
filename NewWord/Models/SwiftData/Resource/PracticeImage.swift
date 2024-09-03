//
//  Image.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/9/2.
//

import UIKit
import SwiftData


@Model
class PracticeImage: Codable {
    
    var id: String?
    var data: Data?

    // 初始化方法
    init(id: String? = nil, data: Data? = nil) {
        self.id = id
        self.data = data
    }

    // CodingKeys 枚舉，用於定義屬性與 JSON 鍵的對應
    private enum CodingKeys: String, CodingKey {
        case id
        case data
    }

    // 解碼方法
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.data = try container.decode(Data.self, forKey: .data)
    }

    // 編碼方法
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(data, forKey: .data)
    }
}

extension PracticeImage {
    var image: UIImage? {
        guard let data else { return nil }
        
        return UIImage(data: data)
    }
}
