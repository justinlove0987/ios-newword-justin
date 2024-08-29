//
//  PracticeThresholdRule.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/8/29.
//

import UIKit
import SwiftData

@Model
class PracticeThresholdRule: Identifiable {
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
}
