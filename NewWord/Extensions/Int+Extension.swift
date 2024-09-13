//
//  Int+Extensions.swift
//  NewWord
//
//  Created by justin on 2024/9/13.
//

import Foundation

extension Int {
    var toInt64: Int64 {
        return Int64(self)
    }
}

extension Optional where Wrapped == Int {
    var toInt64: Int64? {
        guard let intValue = self else {
            return nil
        }
        return Int64(intValue)
    }
}
