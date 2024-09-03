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
        static let lastDataFetchedDate = "lastDataFetchedDate"
    }

    static let shared = UserDefaultsManager()

    private init() {}
    
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

    var lastDataFetchedDate: Date? {
        get {
            return defaults.object(forKey: Keys.lastDataFetchedDate) as? Date
        }

        set {
            defaults.set(newValue, forKey: Keys.lastDataFetchedDate)
        }
    }
}


extension UserDefaultsManager {
    func updateLastFetchedDate() {
        lastDataFetchedDate = Date()
    }

    func hasFetchedDataToday() -> Bool {
        guard let lastFetchedDate = lastDataFetchedDate else {
            return false
        }

        let calendar = Calendar.current
        let todayStart = calendar.startOfDay(for: Date())
        let lastFetchedStart = calendar.startOfDay(for: lastFetchedDate)

        return todayStart == lastFetchedStart
    }
}
