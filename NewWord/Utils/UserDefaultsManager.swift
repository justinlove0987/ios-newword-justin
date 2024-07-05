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
        static let clozeMode = "ClozeMode"
        static let preferredFontSize = "clozeContextFontSize"
    }

    static let shared = UserDefaultsManager()

    private init() {}

    enum ClozeMode: Int {
        case create
        case read
    }

    var clozeMode: ClozeMode {
        get {
            let rawValue = defaults.integer(forKey: Keys.clozeMode)
            let clozeMode = ClozeMode(rawValue: rawValue)!

            return clozeMode
        }
        set {
            let rawValue = newValue.rawValue
            defaults.set(rawValue, forKey: Keys.clozeMode)
        }
    }
    
    var preferredFontSize: CGFloat {
        get {
            return defaults.double(forKey: Keys.preferredFontSize)
        }
        
        set {
            defaults.setValue(newValue, forKey: Keys.preferredFontSize)
        }
    }
}
