//
//  TimepointInformation.swift
//  NewWord
//
//  Created by justin on 2024/9/4.
//

import UIKit
import SwiftData


@Model
class TimepointInformation: Identifiable, Codable {

    var id: String?
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

    class Copy: Identifiable, Hashable {
        var id: String?
        var rangeLocation: Int?
        var rangeLength: Int?
        var markName: String?
        var timeSeconds: Double?

        // 初始化方法
        init(id: String?, location: Int?, length: Int?, markName: String, timeSeconds: Double) {
            self.id = id
            self.rangeLocation = location
            self.rangeLength = length
            self.markName = markName
            self.timeSeconds = timeSeconds
        }

        var range: NSRange? {
            guard let rangeLocation = rangeLocation, let rangeLength = rangeLength else { return nil }
            return NSRange(location: rangeLocation, length: rangeLength)
        }


        static func == (lhs: Copy, rhs: Copy) -> Bool {
            return lhs.id == rhs.id
        }


        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }

    var range: NSRange? {
        guard let rangeLocation = rangeLocation, let rangeLength = rangeLength else { return nil }
        return NSRange(location: rangeLocation, length: rangeLength)
    }
}
