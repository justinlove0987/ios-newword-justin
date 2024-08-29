//
//  PracticePresetManager.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/8/29.
//

import UIKit
import SwiftData

@Model
class PracticePreset: Identifiable {
    
    var practiceType: Int
    
    var firstPracticeGraduationInterval: Double = 1.0
    var firstPracticeEasyInterval: Double = 3.0
    var firstPracticeEase: Double = 2.5
    var firstPracticeLearningPhase: Double  = 1
    
    var forgetPracticeInterval: Double = 1
    var forgetPracticeEase: Double = 2.3
    var forgetPracticeRelearningSteps: Double = 0.0
    
    var practiceThresholdRules: [PracticeThresholdRule]
    var easyBonus: Double = 1.3
    var isSynchronizedWithPractice: Bool = false
    
    // 設定初始化方法
    init(practiceType: Int,
         firstPracticeGraduationInterval: Double,
         firstPracticeEasyInterval: Double,
         firstPracticeEase: Double,
         forgetPracticeInterval: Double,
         forgetPracticeEase: Double,
         practiceThresholdRules: [PracticeThresholdRule],
         easyBonus: Double,
         isSynchronizedWithPractice: Bool) {
        
        self.practiceType = practiceType
        self.firstPracticeGraduationInterval = firstPracticeGraduationInterval
        self.firstPracticeEasyInterval = firstPracticeEasyInterval
        self.firstPracticeEase = firstPracticeEase
        self.forgetPracticeInterval = forgetPracticeInterval
        self.forgetPracticeEase = forgetPracticeEase
        self.practiceThresholdRules = practiceThresholdRules
        self.easyBonus = easyBonus
        self.isSynchronizedWithPractice = isSynchronizedWithPractice
    }
    
}
