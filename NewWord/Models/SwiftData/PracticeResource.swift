//
//  PracticeResource.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/9/2.
//

import UIKit
import SwiftData


@Model
class PracticeResource: Codable {

    var article: Article?

    // 初始化方法
    init(article: Article? = nil) {
        self.article = article
    }

    // CodingKeys 枚舉，用於定義屬性與 JSON 鍵的對應
    private enum CodingKeys: String, CodingKey {
        case article
    }

    // 解碼方法
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.article = try container.decodeIfPresent(Article.self, forKey: .article)
    }

    // 編碼方法
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(article, forKey: .article)
    }
}
