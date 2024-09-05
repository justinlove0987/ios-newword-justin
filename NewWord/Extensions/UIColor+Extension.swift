//
//  UIColor+Extension.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/9/5.
//

import UIKit

extension UIColor {
    // Convert UIColor to Data
    func toData() -> Data? {
        try? NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)
    }
    
    // Convert Data to UIColor using updated method for iOS 12+
    static func fromData(_ data: Data) -> UIColor? {
        try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: data)
    }
}

