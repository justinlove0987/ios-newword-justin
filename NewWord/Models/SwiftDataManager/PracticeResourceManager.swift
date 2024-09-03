//
//  PracticeResourceManager.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/9/3.
//

import UIKit
import SwiftData

@MainActor
class PracticeResourceManager: ModelManager<PracticeResource> {

    static let shared = PracticeResourceManager()

    private override init() {}
}

@MainActor
class ArticleManager: ModelManager<Article> {

    static let shared = ArticleManager()

    private override init() {}
}

@MainActor
class PracticeAudioManager: ModelManager<PracticeAudio> {

    static let shared = PracticeAudioManager()

    private override init() {}
}


@MainActor
class PracticeImageManager: ModelManager<PracticeImage> {

    static let shared = PracticeImageManager()

    private override init() {}
}
