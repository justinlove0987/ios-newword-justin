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

    var id: String?
    var title: String?
    var content: String?
    var uploadedDate: Date?
    var audioResource: PracticeAudio?
    var imageResource: PracticeImage?
    var cefrType: Int?

    // 初始化方法
    init(id: String? = UUID().uuidString,
         title: String? = nil,
         content: String? = nil,
         uploadedDate: Date? = nil,
         audioResource: PracticeAudio? = nil,
         imageResource: PracticeImage? = nil,
         cefrType: Int? = nil) {

        self.id = id
        self.title = title
        self.content = content
        self.uploadedDate = uploadedDate
        self.audioResource = audioResource
        self.imageResource = imageResource
        self.cefrType = cefrType
    }

    // CodingKeys 枚舉，用於定義屬性與 JSON 鍵的對應
    private enum CodingKeys: String, CodingKey {
        case id
        case title
        case content
        case uploadedDate
        case audioResource
        case imageResource
        case cefrType
    }

    // 解碼方法
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.title = try container.decodeIfPresent(String.self, forKey: .title)
        self.content = try container.decodeIfPresent(String.self, forKey: .content)
        self.uploadedDate = try container.decodeIfPresent(Date.self, forKey: .uploadedDate)
        self.audioResource = try container.decodeIfPresent(PracticeAudio.self, forKey: .audioResource)
        self.imageResource = try container.decodeIfPresent(PracticeImage.self, forKey: .imageResource)
        self.cefrType = try container.decodeIfPresent(Int.self, forKey: .cefrType)
    }

    // 編碼方法
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(title, forKey: .title)
        try container.encodeIfPresent(content, forKey: .content)
        try container.encodeIfPresent(uploadedDate, forKey: .uploadedDate)
        try container.encodeIfPresent(audioResource, forKey: .audioResource)
        try container.encodeIfPresent(imageResource, forKey: .imageResource)
        try container.encodeIfPresent(cefrType, forKey: .cefrType)
    }
}

extension Article {

    var formattedUploadedDate: String? {
        guard let uploadedDate else { return nil }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        return dateFormatter.string(from: uploadedDate)
    }

    var text: String? {
        guard let title, let content else { return nil }
        return "\(title)\n\n\(content)"
    }

    var hasAudio: Bool {
        return audioResource?.data != nil
    }

    var hasImage: Bool {
        return imageResource?.data != nil
    }

    var cefr: CEFR? {
        guard let cefrType else { return nil }
        return CEFR(rawValue: cefrType)
    }
}


extension Article {

    class Copy: Identifiable, Hashable {
        var id: String?
        var title: String?
        var content: String?
        var uploadedDate: Date?
        var audioResource: PracticeAudio.Copy?
        var imageResource: PracticeImage.Copy?
        var cefrType: Int?

        init(id: String? = UUID().uuidString,
             title: String? = nil,
             content: String? = nil,
             uploadedDate: Date? = nil,
             audioResource: PracticeAudio.Copy? = nil,
             imageResource: PracticeImage.Copy? = nil,
             cefrType: Int? = nil) {

            self.id = id
            self.title = title
            self.content = content
            self.uploadedDate = uploadedDate
            self.audioResource = audioResource
            self.imageResource = imageResource
            self.cefrType = cefrType
        }

        var formattedUploadedDate: String? {
            guard let uploadedDate else { return nil }
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy/MM/dd"
            return dateFormatter.string(from: uploadedDate)
        }

        var text: String? {
            guard let title, let content else { return nil }
            return "\(title)\n\n\(content)"
        }

        var hasAudio: Bool {
            return audioResource?.data != nil
        }

        var hasImage: Bool {
            return imageResource?.data != nil
        }

        var cefr: CEFR? {
            guard let cefrType else { return nil }
            return CEFR(rawValue: cefrType)
        }

        static func == (lhs: Copy, rhs: Copy) -> Bool {
            return lhs.id == rhs.id
        }


        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }

    func copy() -> Copy {
        // 複製 PracticeAudio
        let copiedAudioResource: PracticeAudio.Copy? = {
            if let audioResource = self.audioResource {
                let copiedTimepoints = audioResource.timepoints.map { timepoint in
                    TimepointInformation.Copy(
                        id: timepoint.id,
                        location: timepoint.rangeLocation,
                        length: timepoint.rangeLength,
                        markName: timepoint.markName,
                        timeSeconds: timepoint.timeSeconds
                    )
                }
                print("foo - \(audioResource.id)")
                return PracticeAudio.Copy(id: audioResource.id, data: audioResource.data, timepoints: copiedTimepoints)
            } else {
                return nil
            }
        }()

        // 複製 PracticeImage
        let copiedImageResource: PracticeImage.Copy? = {
            if let imageResource = self.imageResource {
                return PracticeImage.Copy(id: imageResource.id, data: imageResource.data)
            } else {
                return nil
            }
        }()

        // 回傳複製的 ArticleCopy
        return Copy(
            id: self.id,
            title: self.title,
            content: self.content,
            uploadedDate: self.uploadedDate,
            audioResource: copiedAudioResource,
            imageResource: copiedImageResource,
            cefrType: self.cefrType
        )
    }

    static func copyArticles(from articles: [Article]) -> [Copy] {
        return articles.map { $0.copy() }
    }
}

