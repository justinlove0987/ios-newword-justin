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


@MainActor
class PracticeContextManager: ModelManager<PracticeContext> {

    static let shared = PracticeContextManager()

    private override init() {}
}

@MainActor
class ContextTagManager: ModelManager<ContextTag> {

    static let shared = ContextTagManager()

    private override init() {}
}

@MainActor
class TimepointInformationManager: ModelManager<TimepointInformation> {

    static let shared = TimepointInformationManager()

    private override init() {}
}


