//
//  PrracticeManager.swift
//  NewWord
//
//  Created by justin on 2024/9/1.
//

import UIKit
import SwiftData

@MainActor
class PracticeManager: ModelManager<Practice> {

    static let shared = PracticeManager()

    private override init() {}


    func fetchAll1() -> [Practice] {
        guard let context = context else { return [] }

        do {
            let models = try context.fetch(FetchDescriptor<Practice>())

            return models
        } catch {
            print("Failed to fetch models: \(error)")
            return []
        }
    }


}
