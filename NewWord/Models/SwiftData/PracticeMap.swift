//
//  PracticeMap.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/8/29.
//

import UIKit
import SwiftData

enum PracticeMapType: Int, CaseIterable {
    case blueprint
}

@Model
class PracticeMap: Identifiable, Codable {
    var type: Int
    var practiceMatrix: [[Practice]] = []

    // 設定初始化方法
    init(type: Int, practiceMatrix: [[Practice]]) {
        self.type = type
        self.practiceMatrix = practiceMatrix
    }

    // CodingKeys 枚舉，用於定義屬性與 JSON 鍵的對應
    private enum CodingKeys: String, CodingKey {
        case type
        case practiceMatrix
    }

    // 解碼方法
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.type = try container.decode(Int.self, forKey: .type)
        self.practiceMatrix = try container.decodeIfPresent([[Practice]].self, forKey: .practiceMatrix) ?? []
    }

    // 編碼方法
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encodeIfPresent(practiceMatrix, forKey: .practiceMatrix)
    }
}
