//
//  PracticeMapManager.swift
//  NewWord
//
//  Created by justin on 2024/8/30.
//

import UIKit
import SwiftData

@MainActor
class PracticeMapManager: ModelManager<PracticeMap> {

    static let shared = PracticeMapManager()

    private override init() {}

    
    func fetch(by type: Int) -> PracticeMap? {
        guard let context = context else { return nil }
        let descriptor = FetchDescriptor<PracticeMap>(
            predicate: #Predicate { $0.type == type }
        )
        
        do {
            let models = try context.fetch(descriptor)
            return models.first
        } catch {
            print("Failed to load model.")
            return nil
        }
    }


}
