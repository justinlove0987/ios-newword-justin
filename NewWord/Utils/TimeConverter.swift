//
//  TimeConverter.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/9/19.
//

class TimeConverter {
    
    enum TimeUnit {
        case days(Double)
        case hours(Double)
        case minutes(Double)
        case months(Double)
        case years(Double)
    }
    
    // 將傳入的時間單位轉換為秒
    func convertToSeconds(from unit: TimeUnit) -> Double {
        switch unit {
        case .days(let value):
            return value * 24 * 60 * 60 // 將天轉換為秒
        case .hours(let value):
            return value * 60 * 60 // 將小時轉換為秒
        case .minutes(let value):
            return value * 60 // 將分鐘轉換為秒
        case .months(let value):
            return value * 30 * 24 * 60 * 60 // 將月轉換為秒 (假設1個月為30天)
        case .years(let value):
            return value * 365 * 24 * 60 * 60 // 將年轉換為秒 (假設1年為365天)
        }
    }
}
