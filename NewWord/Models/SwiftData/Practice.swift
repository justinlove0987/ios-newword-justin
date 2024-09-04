//
//  Practice.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/9/2.
//

import UIKit
import SwiftData

@Model
class Practice: Identifiable, Codable, Hashable {
    // MARK: - Properties
    var id: String?
    var typeRawValue: Int?
    var resource: PracticeResource?
    var ugc: PracticeUserGeneratedContent?
    var preset: PracticePreset?
    var records: [PracticeRecord] = []

    // MARK: - Initializer
    init(id: String? = nil,
         typeRawValue: Int? = nil,
         preset: PracticePreset? = nil,
         resource: PracticeResource? = nil,
         ugc: PracticeUserGeneratedContent? = nil,
         records: [PracticeRecord] = []) {

        self.id = id
        self.typeRawValue = typeRawValue
        self.preset = preset
        self.resource = resource
        self.ugc = ugc
        self.records = records
    }

    // MARK: - Codable Keys
    private enum CodingKeys: String, CodingKey {
        case id
        case typeRawValue
        case resource
        case ugc
        case preset
        case records
    }

    // MARK: - Codable Methods
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        typeRawValue = try container.decode(Int.self, forKey: .typeRawValue)
        resource = try container.decodeIfPresent(PracticeResource.self, forKey: .resource)
        ugc = try container.decodeIfPresent(PracticeUserGeneratedContent.self, forKey: .ugc)
        preset = try container.decodeIfPresent(PracticePreset.self, forKey: .preset)
        records = try container.decode([PracticeRecord].self, forKey: .records)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(typeRawValue, forKey: .typeRawValue)
        try container.encodeIfPresent(resource, forKey: .resource)
        try container.encodeIfPresent(ugc, forKey: .ugc)
        try container.encodeIfPresent(preset, forKey: .preset)
        try container.encode(records, forKey: .records)
    }
}

extension Practice {
    class Copy: Identifiable, Hashable {

        var id: String?
        var typeRawValue: Int?
        var resource: PracticeResource.Copy?

        init(id: String? = nil,
             typeRawValue: Int? = nil,
             resource: PracticeResource.Copy? = nil) {

            self.id = id
            self.typeRawValue = typeRawValue
            self.resource = resource
        }

        static func == (lhs: Copy, rhs: Copy) -> Bool {
            return lhs.id == rhs.id
        }


        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }

    func copy() -> Copy {
        return Copy(id: self.id,
                    typeRawValue: self.typeRawValue,
                    resource: self.resource?.copy()
        )
    }
}

extension Practice {

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

    var type: PracticeType? {
        guard let typeRawValue else { return nil }

        return PracticeType(rawValue: typeRawValue)
    }
}
