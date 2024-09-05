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
    var type: Int
    var context: String
    var resource: PracticeContextResource
    var practiceMap: PracticeMap

    // 設定初始化方法
    init(type: Int, context: String, resource: PracticeContextResource, practiceMap: PracticeMap) {
        self.type = type
        self.context = context
        self.resource = resource
        self.practiceMap = practiceMap
    }
}

extension PracticeContext {
    var practiceRecord: [DefaultPracticeRecord] {
        return []
    }

    var linkedResource: Any? {
        guard let type = ContextType(rawValue: type) else { return nil }
        
        switch type {
        case .word:
            return fetchLinkedWord() // 實現 fetchLinkedWord 來獲取對應的 Word 資源
        default:
            return nil
        }
    }

    private func fetchLinkedWord() -> Vocabulary? {
        // 根據 context 或其他信息來查找對應的 Word 資源
        return nil // 這裡返回實際的 Word 資源
    }
}

