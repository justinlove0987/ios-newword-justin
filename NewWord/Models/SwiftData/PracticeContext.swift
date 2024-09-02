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
//    var resource:
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

    var linkedResource: Any? {
        guard let type = PracticeContextType(rawValue: type) else { return nil }
        
        switch type {
        case .word:
            return fetchLinkedWord() // 實現 fetchLinkedWord 來獲取對應的 Word 資源
        default:
            return nil
        }
    }

    private func fetchLinkedWord() -> CDWord? {
        // 根據 context 或其他信息來查找對應的 Word 資源
        return nil // 這裡返回實際的 Word 資源
    }
}

