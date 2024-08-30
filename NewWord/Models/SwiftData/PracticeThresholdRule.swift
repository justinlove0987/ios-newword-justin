//
//  PracticeThresholdRule.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/8/29.
//

import UIKit
import SwiftData

@Model
class PracticeThresholdRule: Identifiable, Codable {
//    @Attribute(originalName: "conditionType")
    var id: UUID
    var conditionType: Int
    var thresholdValue: Int
    var actionType: Int
    
    // 設定初始化方法
    init(id: UUID = UUID(), conditionType: Int, thresholdValue: Int, actionType: Int) {
        self.id = id
        self.conditionType = conditionType
        self.thresholdValue = thresholdValue
        self.actionType = actionType
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case conditionType
        case thresholdValue
        case actionType
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.conditionType = try container.decode(Int.self, forKey: .conditionType)
        self.thresholdValue = try container.decode(Int.self, forKey: .thresholdValue)
        self.actionType = try container.decode(Int.self, forKey: .actionType)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(conditionType, forKey: .conditionType)
        try container.encode(thresholdValue, forKey: .thresholdValue)
        try container.encode(actionType, forKey: .actionType)
    }

}
