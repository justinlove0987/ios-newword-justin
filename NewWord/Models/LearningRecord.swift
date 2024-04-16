//
//  ReviewRecord.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/4/13.
//

import Foundation


struct LearningRecord {
    
    enum Status {
        case correct
        case incorrect
    }
    
    let date: Date
    let dueDate: Date
    let interval: Double
    let totalTime: Int = 0
    let status: Status
}
