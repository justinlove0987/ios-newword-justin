//
//  Practice.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/9/2.
//

import UIKit
import SwiftData

@Model
class Practice: Identifiable {

    var type: Int
    var resource: PracticeResource?
    var ugc: PracticeUserGeneratedContent?
    var preset: PracticePreset?
    var records: [PracticeRecord] = []

    init(type: Int, 
         preset: PracticePreset,
         resource: PracticeResource,
         ugc: PracticeUserGeneratedContent? = nil,
         records: [PracticeRecord] = []) {
        
        self.type = type
        self.preset = preset
        self.resource = resource
        self.ugc = ugc
        self.records = records
    }
}
