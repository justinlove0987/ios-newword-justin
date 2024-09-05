//
//  PracticeTag.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/9/4.
//


import UIKit
import SwiftData

@Model
class ContextTag: Identifiable, Codable {
    
    // MARK: - Properties
    var id: String?
    var number: Int?
    var text: String?
    var rangeLocation: Int?
    var rangelength: Int?
    var translation: String?
    var typeRawValue: Int?
    var tagColor: Data?
    var contentColor: Data?
    var audio: PracticeAudio?
    
    // MARK: - Initializer
    init(id: String? = nil,
         text: String? = nil,
         number: Int? = nil,
         rangeLocation: Int? = nil,
         rangeLength: Int? = nil,
         translation: String? = nil,
         typeRawValue: Int? = nil,
         tagColor: Data? = nil,
         contentColor: Data? = nil,
         audio: PracticeAudio? = nil
    ) {
        self.id = id
        self.text = text
        self.rangeLocation = rangeLocation
        self.rangelength = rangeLength
        self.number = number
        self.translation = translation
        self.typeRawValue = typeRawValue
        self.tagColor = tagColor
        self.contentColor = contentColor
        self.audio = audio
    }
    
    // MARK: - Codable Keys
    private enum CodingKeys: String, CodingKey {
        case id
        case rangeLocation
        case rangelength
        case number
        case translation
        case typeRawValue
        case tagColor
        case contentColor
        case audio
    }
    
    // MARK: - Codable Methods
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        rangeLocation = try container.decodeIfPresent(Int.self, forKey: .rangeLocation)
        rangelength = try container.decodeIfPresent(Int.self, forKey: .rangelength)
        number = try container.decodeIfPresent(Int.self, forKey: .number)
        translation = try container.decodeIfPresent(String.self, forKey: .translation)
        typeRawValue = try container.decodeIfPresent(Int.self, forKey: .typeRawValue)
        tagColor = try container.decodeIfPresent(Data.self, forKey: .tagColor)
        contentColor = try container.decodeIfPresent(Data.self, forKey: .contentColor)
        audio = try container.decodeIfPresent(PracticeAudio.self, forKey: .audio)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encodeIfPresent(rangeLocation, forKey: .rangeLocation)
        try container.encodeIfPresent(rangelength, forKey: .rangelength)
        try container.encodeIfPresent(number, forKey: .number)
        try container.encodeIfPresent(translation, forKey: .translation)
        try container.encodeIfPresent(typeRawValue, forKey: .typeRawValue)
        try container.encodeIfPresent(tagColor, forKey: .tagColor)
        try container.encodeIfPresent(contentColor, forKey: .contentColor)
        try container.encodeIfPresent(audio, forKey: .audio)
    }
}

extension ContextTag {
    var type: ContextType? {
        guard let typeRawValue else { return nil }
        
        return ContextType(rawValue: typeRawValue)
    }
}

extension ContextTag {
    class Copy: Identifiable, Hashable {
        
        var id: String?
        var text: String?
        var rangeLocation: Int?
        var rangelength: Int?
        var number: Int?
        var translation: String?
        var typeRawValue: Int?
        var tagColor: Data?
        var contentColor: Data?
        var audio: PracticeAudio.Copy?
        
        init(id: String? = nil,
             text: String? = nil,
             number: Int? = nil,
             rangeLocation: Int? = nil,
             rangeLength: Int? = nil,
             translation: String? = nil,
             typeRawValue: Int? = nil,
             tagColor: Data? = nil,
             contentColor: Data? = nil,
             audio: PracticeAudio.Copy? = nil
        ) {
            self.id = id
            self.text = text
            self.rangeLocation = rangeLocation
            self.rangelength = rangeLength
            self.number = number
            self.translation = translation
            self.typeRawValue = typeRawValue
            self.tagColor = tagColor
            self.contentColor = contentColor
            self.audio = audio
        }
        
        static func == (lhs: Copy, rhs: Copy) -> Bool {
            return lhs.id == rhs.id
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
        
        var type: ContextType? {
            guard let typeRawValue else { return nil }
            
            return ContextType(rawValue: typeRawValue)
        }
        
        func toContextTag() -> ContextTag {
            return ContextTag(
                id: self.id,
                text: self.text,
                number: self.number,
                rangeLocation: self.rangeLocation,
                rangeLength: self.rangelength,
                translation: self.translation,
                typeRawValue: self.typeRawValue,
                tagColor: self.tagColor,
                contentColor: self.contentColor,
                audio: nil
            )
        }
        
        var range: NSRange? {
            guard let rangeLocation,
                  let rangelength else { return nil }
            
            return NSRange(location: rangeLocation, length: rangelength)
        }
        
        func isEqualTo(_ other: ContextTag.Copy) -> Bool {
            return self.range == other.range &&
                   self.type == other.type
//                   self.tagType == other.tagType
        }
        
        func isEqualTo(textType: ContextType, range: NSRange) -> Bool {
            return self.range == range &&
                   self.type == type
//                   self.tagType == tagType
        }
        
        func getTagIndex(in text: String) -> String.Index? {
            let location = range!.location - 1

            if let stringIndex = text.index(text.startIndex, offsetBy: location, limitedBy: text.endIndex) {
                return stringIndex
            }
            
            return nil
        }
    }
    
    func copy() -> Copy {
        return Copy(
            id: self.id,
            text: self.text,
            number: self.number,
            rangeLocation: self.rangeLocation,
            rangeLength: self.rangelength,
            translation: self.translation,
            typeRawValue: self.typeRawValue,
            tagColor: self.tagColor,
            contentColor: self.contentColor,
            audio: self.audio?.copy()
        )
    }
}
