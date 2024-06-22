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
    }

    static let shared = UserDefaultsManager()


    private init() {}

    enum ClozeMode: Int {
        case test
        case revise
    }

    var _clozeMode: Int {
        get {
            return defaults.integer(forKey: Keys.clozeMode)
        }
        set {
            defaults.set(newValue, forKey: Keys.clozeMode)
        }
    }

    var clozeMode: ClozeMode? {
        return ClozeMode(rawValue: _clozeMode)
    }
}
