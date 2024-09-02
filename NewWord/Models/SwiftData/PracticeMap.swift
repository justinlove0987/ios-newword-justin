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
    var practiceMatrix: [[Practice]] = []

    // 設定初始化方法
    init(practiceMatrix: [[Practice]]) {
        self.practiceMatrix = practiceMatrix
    }
}
