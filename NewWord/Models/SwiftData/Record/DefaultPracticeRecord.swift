//
//  PracticeRecord.swift
//  NewWord
//
//  Created by justin on 2024/8/30.
//

import UIKit
import SwiftData


@Model
class DefaultPracticeRecord: Identifiable, Codable {
    var dueDate: Date
    var ease: Double
    var learnedDate: Date
    var stateRawValue: Int
    var statusRawValue: Int
    var duration: Double

    // 設定初始化方法
    init(learnedDate: Date = Date(),
         dueDate: Date, 
         ease: Double,
         stateRawValue: Int,
         statusRawValue: Int,
         duration: Double)
    {
        self.learnedDate = learnedDate
        self.dueDate = dueDate
        self.ease = ease
        self.stateRawValue = stateRawValue
        self.statusRawValue = statusRawValue
        self.duration = duration
    }
    
    // 定義編碼和解碼所需的鍵
    private enum CodingKeys: String, CodingKey {
        case id
        case dueDate
        case ease
        case learnedDate
        case stateRawValue
        case statusRawValue
        case time
    }

    // 解碼方法
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.dueDate = try container.decode(Date.self, forKey: .dueDate)
        self.ease = try container.decode(Double.self, forKey: .ease)
        self.learnedDate = try container.decode(Date.self, forKey: .learnedDate)
        self.stateRawValue = try container.decode(Int.self, forKey: .stateRawValue)
        self.statusRawValue = try container.decode(Int.self, forKey: .statusRawValue)
        self.duration = try container.decode(Double.self, forKey: .time)
    }
    
    // 編碼方法
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(dueDate, forKey: .dueDate)
        try container.encode(ease, forKey: .ease)
        try container.encode(learnedDate, forKey: .learnedDate)
        try container.encode(stateRawValue, forKey: .stateRawValue)
        try container.encode(statusRawValue, forKey: .statusRawValue)
        try container.encode(duration, forKey: .time)
    }
}
