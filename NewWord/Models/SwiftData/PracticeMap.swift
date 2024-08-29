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
    var practicePreset: [PracticePreset] = []

    
    // 設定初始化方法
    init(id: UUID = UUID()) {
        self.id = id
    }
}
