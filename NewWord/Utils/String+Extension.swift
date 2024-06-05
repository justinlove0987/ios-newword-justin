//
//  String+Extension.swift
//  NewWord
//
//  Created by justin on 2024/6/4.
//

import Foundation

extension String {
    var containsChineseCharacters: Bool {
        return self.range(of: "\\p{Han}", options: .regularExpression) != nil
    }
}
