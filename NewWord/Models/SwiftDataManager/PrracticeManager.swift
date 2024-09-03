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
}
