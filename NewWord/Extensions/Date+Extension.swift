//
//  Date+Extension.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/9/19.
//

import Foundation

extension Date {
    func adding(seconds: TimeInterval) -> Date {
        return self.addingTimeInterval(seconds)
    }
}
