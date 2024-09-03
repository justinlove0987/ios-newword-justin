//
//  PracticePresetManager.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/8/29.
//

import UIKit
import SwiftData

@Model
class DefaultPracticePreset: Identifiable, Codable {

    var id: UUID = UUID()
    var practiceType: Int
    var firstPracticeGraduationInterval: Double
    var firstPracticeEasyInterval: Double
    var firstPracticeEase: Double
    var firstPracticeLearningPhase: Double
    var forgetPracticeInterval: Double
    var forgetPracticeEase: Double
    var forgetPracticeRelearningSteps: Double
    var practiceThresholdRules: [PracticeThresholdRule]
    var easyBonus: Double
    var isSynchronizedWithPracticePreset: Bool
    var synchronizedPracticePreset: DefaultPracticePreset?

    init(practiceType: Int = 0,
         firstPracticeGraduationInterval: Double = 1.0,
         firstPracticeEasyInterval: Double = 3.0,
         firstPracticeEase: Double = 2.5,
         firstPracticeLearningPhase: Double = 1.0,
         forgetPracticeInterval: Double = 1.0,
         forgetPracticeEase: Double = 2.3,
         forgetPracticeRelearningSteps: Double = 0.0,
         practiceThresholdRules: [PracticeThresholdRule] = [],
         easyBonus: Double = 1.3,
         isSynchronizedWithPracticePreset: Bool = false,
         synchronizedPracticePreset: DefaultPracticePreset? = nil) {

        self.practiceType = practiceType
        self.firstPracticeGraduationInterval = firstPracticeGraduationInterval
        self.firstPracticeEasyInterval = firstPracticeEasyInterval
        self.firstPracticeEase = firstPracticeEase
        self.firstPracticeLearningPhase = firstPracticeLearningPhase
        self.forgetPracticeInterval = forgetPracticeInterval
        self.forgetPracticeEase = forgetPracticeEase
        self.forgetPracticeRelearningSteps = forgetPracticeRelearningSteps
        self.practiceThresholdRules = practiceThresholdRules
        self.easyBonus = easyBonus
        self.isSynchronizedWithPracticePreset = isSynchronizedWithPracticePreset
        self.synchronizedPracticePreset = synchronizedPracticePreset
    }

    // 自定義編碼和解碼
    private enum CodingKeys: String, CodingKey {
        case id
        case practiceType
        case firstPracticeGraduationInterval
        case firstPracticeEasyInterval
        case firstPracticeEase
        case firstPracticeLearningPhase
        case forgetPracticeInterval
        case forgetPracticeEase
        case forgetPracticeRelearningSteps
        case practiceThresholdRules
        case easyBonus
        case isSynchronizedWithPracticePreset
        case synchronizedPracticePreset
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.practiceType = try container.decode(Int.self, forKey: .practiceType)
        self.firstPracticeGraduationInterval = try container.decode(Double.self, forKey: .firstPracticeGraduationInterval)
        self.firstPracticeEasyInterval = try container.decode(Double.self, forKey: .firstPracticeEasyInterval)
        self.firstPracticeEase = try container.decode(Double.self, forKey: .firstPracticeEase)
        self.firstPracticeLearningPhase = try container.decode(Double.self, forKey: .firstPracticeLearningPhase)
        self.forgetPracticeInterval = try container.decode(Double.self, forKey: .forgetPracticeInterval)
        self.forgetPracticeEase = try container.decode(Double.self, forKey: .forgetPracticeEase)
        self.forgetPracticeRelearningSteps = try container.decode(Double.self, forKey: .forgetPracticeRelearningSteps)
        self.practiceThresholdRules = try container.decode([PracticeThresholdRule].self, forKey: .practiceThresholdRules)
        self.easyBonus = try container.decode(Double.self, forKey: .easyBonus)
        self.isSynchronizedWithPracticePreset = try container.decode(Bool.self, forKey: .isSynchronizedWithPracticePreset)
        self.synchronizedPracticePreset = try container.decodeIfPresent(DefaultPracticePreset.self, forKey: .synchronizedPracticePreset)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(practiceType, forKey: .practiceType)
        try container.encode(firstPracticeGraduationInterval, forKey: .firstPracticeGraduationInterval)
        try container.encode(firstPracticeEasyInterval, forKey: .firstPracticeEasyInterval)
        try container.encode(firstPracticeEase, forKey: .firstPracticeEase)
        try container.encode(firstPracticeLearningPhase, forKey: .firstPracticeLearningPhase)
        try container.encode(forgetPracticeInterval, forKey: .forgetPracticeInterval)
        try container.encode(forgetPracticeEase, forKey: .forgetPracticeEase)
        try container.encode(forgetPracticeRelearningSteps, forKey: .forgetPracticeRelearningSteps)
        try container.encode(practiceThresholdRules, forKey: .practiceThresholdRules)
        try container.encode(easyBonus, forKey: .easyBonus)
        try container.encode(isSynchronizedWithPracticePreset, forKey: .isSynchronizedWithPracticePreset)
        try container.encodeIfPresent(synchronizedPracticePreset, forKey: .synchronizedPracticePreset)
    }
}
