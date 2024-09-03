//
//  Article.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/9/2.
//


import UIKit
import SwiftData

@Model
class Article: Codable {

    var id: String?
    var title: String?
    var content: String?
    var uploadedDate: Date?
    var audioResource: PracticeAudio?
    var imageResource: PracticeImage?
    var cefrType: Int?

    // 初始化方法
    init(id: String?,
         title: String?,
         content: String?,
         uploadedDate: Date?,
         audio: PracticeAudio? = nil,
         image: PracticeImage? = nil,
         cefrType: Int? = nil) {

        self.id = id
        self.title = title
        self.content = content
        self.uploadedDate = uploadedDate
        self.audioResource = audio
        self.imageResource = image
        self.cefrType = cefrType
    }

    // CodingKeys 枚舉，用於定義屬性與 JSON 鍵的對應
    private enum CodingKeys: String, CodingKey {
        case id
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
        self.id = try container.decode(String.self, forKey: .id)
        self.title = try container.decode(String.self, forKey: .title)
        self.content = try container.decode(String.self, forKey: .content)
        self.uploadedDate = try container.decode(Date.self, forKey: .uploadedDate)
        self.audioResource = try container.decodeIfPresent(PracticeAudio.self, forKey: .audio)
        self.imageResource = try container.decodeIfPresent(PracticeImage.self, forKey: .image)
        self.cefrType = try container.decodeIfPresent(Int.self, forKey: .cefrType)
    }

    // 編碼方法
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(content, forKey: .content)
        try container.encode(uploadedDate, forKey: .uploadedDate)
        try container.encodeIfPresent(audioResource, forKey: .audio)
        try container.encodeIfPresent(imageResource, forKey: .image)
        try container.encodeIfPresent(cefrType, forKey: .cefrType)
    }
}

extension Article {
    var formattedUploadedDate: String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"

        return dateFormatter.string(from: uploadedDate!)
    }

    var text: String? {
        guard let title else { return nil }
        guard let content else { return nil }

        return "\(title)\n\n\(String(describing: content))"
    }

    var hasImage: Bool {
        return imageResource?.data != nil
    }

    var cefr: CEFR? {
        guard let cefrType else { return nil }

        let cefr = CEFR(rawValue: cefrType)

        return cefr
    }
}
