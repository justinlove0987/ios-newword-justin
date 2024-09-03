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
class PracticeMap: Identifiable {
    var type: Int
    var sequences: [PracticeSequence] = []

    // 設定初始化方法
    init(type: Int, sequences: [PracticeSequence]) {
        self.type = type
        self.sequences = sequences
    }
}
