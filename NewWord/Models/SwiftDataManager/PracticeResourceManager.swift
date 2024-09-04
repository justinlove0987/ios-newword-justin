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
    
    func fetch(byId id: String) -> Article? {
        guard let context = context else { return nil }
        let descriptor = FetchDescriptor<Article>(
            predicate: #Predicate { $0.id == id }
        )
        
        do {
            let models = try context.fetch(descriptor)
            return models.first
        } catch {
            print("Failed to load model.")
            return nil
        }
    }
    
    // 更新記錄
    func updateAudio(id: String, audioData: Data?, with updates: ((Article) -> Void)? = nil) {
        guard let context = context else { return }

        if let model = fetch(byId: id) {
            
            model.audioResource?.data = audioData
            
            updates?(model)

            do {
                try context.save()
            } catch {
                print("Failed to update model: \(error)")
            }
        } else {
            print("Model with ID \(id) not found")
        }
    }

    // 更新記錄
    func updateImage(id: String, imageData: Data?, with updates: ((Article) -> Void)? = nil) {
        guard let context = context else { return }

        if let model = fetch(byId: id) {

            model.imageResource?.data = imageData

            updates?(model)

            do {
                try context.save()
            } catch {
                print("Failed to update model: \(error)")
            }
        } else {
            print("Model with ID \(id) not found")
        }
    }

    
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
