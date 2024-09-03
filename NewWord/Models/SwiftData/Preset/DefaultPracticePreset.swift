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

    var practiceType: Int = 0
    var firstPracticeGraduationInterval: Double = 1.0
    var firstPracticeEasyInterval: Double = 3.0
    var firstPracticeEase: Double = 2.5
    var firstPracticeLearningPhase: Double = 1.0
    var forgetPracticeInterval: Double = 1.0
    var forgetPracticeEase: Double = 2.3
    var forgetPracticeRelearningSteps: Double = 0.0
    var practiceThresholdRules: [PracticeThresholdRule] = []
    var easyBonus: Double = 1.3
    var isSynchronizedWithPracticePreset: Bool = false
//    var synchronizedPracticePreset: DefaultPracticePreset? = nil

    init() {}

    init(practiceType: Int,
         firstPracticeGraduationInterval: Double,
         firstPracticeEasyInterval: Double,
         firstPracticeEase: Double,
         firstPracticeLearningPhase: Double,
         forgetPracticeInterval: Double,
         forgetPracticeEase: Double,
         forgetPracticeRelearningSteps: Double,
         practiceThresholdRules: [PracticeThresholdRule],
         easyBonus: Double,
         isSynchronizedWithPracticePreset: Bool,
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
//        self.synchronizedPracticePreset = synchronizedPracticePreset
    }

    // 自定義編碼和解碼
    private enum CodingKeys: String, CodingKey {
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
//        self.synchronizedPracticePreset = try container.decodeIfPresent(DefaultPracticePreset.self, forKey: .synchronizedPracticePreset)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
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
//        try container.encodeIfPresent(synchronizedPracticePreset, forKey: .synchronizedPracticePreset)
    }
}
