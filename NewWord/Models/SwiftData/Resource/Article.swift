//
//  Article.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/9/2.
//


import UIKit
import SwiftData

@Model
class Article: Identifiable, Codable {

    var title: String
    var content: String
    var uploadedDate: Date
    var audio: PracticeAudio?
    var image: PracticeImage?
    var cefrType: Int?

    // 初始化方法
    init(title: String,
         content: String,
         uploadedDate: Date,
         audio: PracticeAudio? = nil,
         image: PracticeImage? = nil,
         cefrType: Int? = nil) {
        self.title = title
        self.content = content
        self.uploadedDate = uploadedDate
        self.audio = audio
        self.image = image
        self.cefrType = cefrType
    }

    // CodingKeys 枚舉，用於定義屬性與 JSON 鍵的對應
    private enum CodingKeys: String, CodingKey {
        case title
        case content
        case uploadedDate
        case audio
        case image
        case cefrType
    }

    // 解碼方法
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try container.decode(String.self, forKey: .title)
        self.content = try container.decode(String.self, forKey: .content)
        self.uploadedDate = try container.decode(Date.self, forKey: .uploadedDate)
        self.audio = try container.decodeIfPresent(PracticeAudio.self, forKey: .audio)
        self.image = try container.decodeIfPresent(PracticeImage.self, forKey: .image)
        self.cefrType = try container.decodeIfPresent(Int.self, forKey: .cefrType)
    }

    // 編碼方法
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(content, forKey: .content)
        try container.encode(uploadedDate, forKey: .uploadedDate)
        try container.encodeIfPresent(audio, forKey: .audio)
        try container.encodeIfPresent(image, forKey: .image)
        try container.encodeIfPresent(cefrType, forKey: .cefrType)
    }
}
