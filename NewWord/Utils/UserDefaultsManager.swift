//
//  UserDefaultsManager.swift
//  NewWord
//
//  Created by justin on 2024/6/23.
//

import Foundation


class UserDefaultsManager {

    private let defaults = UserDefaults.standard

    private enum Keys {
        static let clozeMode = "clozeMode"
        static let preferredFontSize = "clozeContextFontSize"
        static let preferredLineSpacing = "preferredLineSpacing"
    }

    static let shared = UserDefaultsManager()

    private init() {}

    enum ClozeMode: Int {
        case create
        case read
    }
    
    var preferredFontSize: CGFloat {
        get {
            return defaults.double(forKey: Keys.preferredFontSize)
        }
        
        set {
            defaults.setValue(newValue, forKey: Keys.preferredFontSize)
        }
    }

    var preferredLineSpacing: CGFloat {
        get {
            return defaults.double(forKey: Keys.preferredLineSpacing)
        }

        set {
            defaults.setValue(newValue, forKey: Keys.preferredLineSpacing)
        }
    }
}
