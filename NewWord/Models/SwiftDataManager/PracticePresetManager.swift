//
//  PracticePresetManager.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/8/29.
//


import UIKit
import SwiftData

@MainActor
class PracticePresetManager: ModelManager<DefaultPracticePreset> {
    
    static let shared = PracticePresetManager()
    
    private override init() {}
    
    
}
