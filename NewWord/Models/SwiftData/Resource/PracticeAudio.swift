//
//  Audio.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/9/2.
//

import UIKit
import SwiftData

@Model
class PracticeAudio: Identifiable, Codable {

    var id: String?
    var data: Data?
    var timepoints: [TimepointInformation] = []

    // 初始化方法
    init(id: String? = nil,
         data: Data? = nil,
         timepoints: [TimepointInformation] = []) {

        self.id = id
        self.data = data
        self.timepoints = timepoints
    }

    // CodingKeys 枚舉，用於定義屬性與 JSON 鍵的對應
    private enum CodingKeys: String, CodingKey {
        case id
        case data
        case timepoints
    }

    // 解碼方法
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.data = try container.decodeIfPresent(Data.self, forKey: .data)
        self.timepoints = try container.decode([TimepointInformation].self, forKey: .timepoints)
    }

    // 編碼方法
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(data, forKey: .data)
        try container.encode(timepoints, forKey: .timepoints)
    }
}

extension PracticeAudio {

    class Copy: Identifiable, Hashable {
        var id: String?
        var data: Data?
        var timepoints: [TimepointInformation.Copy] = []

        init(id: String? = nil,
             data: Data? = nil,
             timepoints: [TimepointInformation.Copy] = []) {

            self.id = id
            self.data = data
            self.timepoints = timepoints
        }

        static func == (lhs: Copy, rhs: Copy) -> Bool {
            return lhs.id == rhs.id
        }


        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }
}

