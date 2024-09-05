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
    var serverProvidedContent: PracticeServerProvidedContent?
    var userGeneratedContent: PracticeUserGeneratedContent?
    var preset: PracticePreset?
    var records: [PracticeRecord] = []

    // MARK: - Initializer
    
    init(id: String? = nil,
         typeRawValue: Int? = nil,
         preset: PracticePreset? = nil,
         serverProvidedContent: PracticeServerProvidedContent? = nil,
         userGeneratedContent: PracticeUserGeneratedContent? = nil,
         records: [PracticeRecord] = []) {

        self.id = id
        self.typeRawValue = typeRawValue
        self.preset = preset
        self.serverProvidedContent = serverProvidedContent
        self.userGeneratedContent = userGeneratedContent
        self.records = records
    }

    // MARK: - Codable Keys
    
    private enum CodingKeys: String, CodingKey {
        case id
        case typeRawValue
        case serverProvidedContent
        case userGeneratedContent
        case preset
        case records
    }

    // MARK: - Codable Methods
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        typeRawValue = try container.decode(Int.self, forKey: .typeRawValue)
        serverProvidedContent = try container.decodeIfPresent(PracticeServerProvidedContent.self, forKey: .serverProvidedContent)
        userGeneratedContent = try container.decodeIfPresent(PracticeUserGeneratedContent.self, forKey: .userGeneratedContent)
        preset = try container.decodeIfPresent(PracticePreset.self, forKey: .preset)
        records = try container.decode([PracticeRecord].self, forKey: .records)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(typeRawValue, forKey: .typeRawValue)
        try container.encodeIfPresent(serverProvidedContent, forKey: .serverProvidedContent)
        try container.encodeIfPresent(userGeneratedContent, forKey: .userGeneratedContent)
        try container.encodeIfPresent(preset, forKey: .preset)
        try container.encode(records, forKey: .records)
    }
}

extension Practice {
    class Copy: Identifiable, Hashable {

        var id: String?
        var typeRawValue: Int?
        var serverProvidedContent: PracticeServerProvidedContent.Copy?
        var userGeneratedContent: PracticeUserGeneratedContent.Copy?
        var preset: PracticePreset?
        var records: [PracticeRecord] = []

        init(id: String? = nil,
             typeRawValue: Int? = nil,
             userGeneratedContent: PracticeUserGeneratedContent.Copy? = nil,
             serverProvidedContent: PracticeServerProvidedContent.Copy? = nil,
             preset: PracticePreset? = nil,
             records: [PracticeRecord] = []
        ) {

            self.id = id
            self.typeRawValue = typeRawValue
            self.userGeneratedContent = userGeneratedContent
            self.serverProvidedContent = serverProvidedContent
            self.preset = preset
            self.records = records
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
                    serverProvidedContent: self.serverProvidedContent?.copy()
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
