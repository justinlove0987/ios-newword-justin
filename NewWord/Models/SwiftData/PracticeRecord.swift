//
//  PracticeRecord.swift
//  NewWord
//
//  Created by justin on 2024/8/30.
//

import UIKit
import SwiftData


@Model
class PracticeRecord: Identifiable {
    var id: UUID
    var dueDate: Date
    var ease: Double
    var learnedDate: Date
    var stateRawValue: Int
    var statusRawValue: Int
    var time: Double

    // 設定初始化方法
    init(id: UUID = UUID(), 
         learnedDate: Date = Date(),
         dueDate: Date, 
         ease: Double,
         stateRawValue: Int,
         statusRawValue: Int,
         time: Double)
    {
        self.id = id
        self.learnedDate = learnedDate
        self.dueDate = dueDate
        self.ease = ease
        self.stateRawValue = stateRawValue
        self.statusRawValue = statusRawValue
        self.time = time
    }
}
