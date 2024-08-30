//
//  PracticeContext.swift
//  NewWord
//
//  Created by justin on 2024/8/30.
//

import UIKit
import SwiftData


@Model
class PracticeContext: Identifiable {
    var id: UUID
    var context: String
    var type: Int
    var practiceMaps: [PracticeMap]


    // 設定初始化方法
    init(id: UUID = UUID(), context: String, type: Int, practiceMaps: [PracticeMap]) {
        self.id = id
        self.context = context
        self.type = type
        self.practiceMaps = practiceMaps
    }
}

extension PracticeContext {

    var practiceRecord: [PracticeRecord] {
        return []
    }

}
