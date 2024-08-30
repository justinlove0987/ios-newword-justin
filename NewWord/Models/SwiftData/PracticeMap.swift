//
//  PracticeMap.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/8/29.
//

import UIKit
import SwiftData


@Model
class PracticeMap: Identifiable {
    var id: UUID
    var practicePresetMatrix: [[PracticePreset]] = []
    var practiceRecord: [PracticeRecord] = []

    // 設定初始化方法
    init(id: UUID = UUID(), practicePresetMatrix: [[PracticePreset]], practiceRecord: [PracticeRecord]) {
        self.id = id
        self.practicePresetMatrix = practicePresetMatrix
        self.practiceRecord = practiceRecord
    }

}
