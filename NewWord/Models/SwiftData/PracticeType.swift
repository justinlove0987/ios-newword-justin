//
//  PracticeMode.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/8/27.
//

import Foundation


enum PracticeType: Int, CaseIterable {
    case listenAndTranslate
    case listenReadChineseAndTypeEnglish
    case listenAndTypeEnglish
    case readAndTranslate
    
    var title: String {
        switch self {
        case .listenAndTranslate:
            return "聆聽並翻譯"
        case .listenReadChineseAndTypeEnglish:
            return "聆聽、閱讀中文並輸入英文"
        case .listenAndTypeEnglish:
            return "聆聽並輸入英文"
        case .readAndTranslate:
            return "閱讀並翻譯"
        }
    }
}
