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

        self.id = UUID().uuidString
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

@Model
class TimepointInformation: Identifiable, Codable {

    var id: UUID = UUID() // Identifiable 需要的 id 屬性
    var rangeLocation: Int?
    var rangeLength: Int?
    var markName: String
    var timeSeconds: Double

    // 初始化方法
    init(location: Int?, length: Int?, markName: String, timeSeconds: Double) {
        self.rangeLocation = location
        self.rangeLength = length
        self.markName = markName
        self.timeSeconds = timeSeconds
    }

    // CodingKeys 枚舉，用於定義屬性與 JSON 鍵的對應
    private enum CodingKeys: String, CodingKey {
        case rangeLocation
        case rangeLength
        case markName
        case timeSeconds
    }

    // 解碼方法
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.rangeLocation = try container.decodeIfPresent(Int.self, forKey: .rangeLocation)
        self.rangeLength = try container.decodeIfPresent(Int.self, forKey: .rangeLength)
        self.markName = try container.decode(String.self, forKey: .markName)
        self.timeSeconds = try container.decode(Double.self, forKey: .timeSeconds)
    }

    // 編碼方法
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(rangeLocation, forKey: .rangeLocation)
        try container.encode(rangeLength, forKey: .rangeLength)
        try container.encode(markName, forKey: .markName)
        try container.encode(timeSeconds, forKey: .timeSeconds)
    }
}

extension TimepointInformation {
    var range: NSRange? {
        guard let rangeLocation = rangeLocation, let rangeLength = rangeLength else { return nil }
        return NSRange(location: rangeLocation, length: rangeLength)
    }
}
