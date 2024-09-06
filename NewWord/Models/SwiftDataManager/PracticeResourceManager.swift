//
//  PracticeResourceManager.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/9/3.
//

import UIKit
import SwiftData

@MainActor
class PracticeResourceManager: ModelManager<PracticeServerProvidedContent> {

    static let shared = PracticeResourceManager()

    private override init() {}
}

@MainActor
class ArticleManager: ModelManager<PracticeTagArticle> {

    static let shared = ArticleManager()

    private override init() {}
    
    func fetch(byId id: String) -> PracticeTagArticle? {
        guard let context = context else { return nil }
        let descriptor = FetchDescriptor<PracticeTagArticle>(
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
    
    func updateArticle(withId id: String, from copy: PracticeTagArticle.Copy, applying updates: ((PracticeTagArticle) -> Void)? = nil) {
        guard let context = context else {
            print("No context available")
            return
        }
        
        guard let article = fetch(byId: id) else {
            print("Article with ID \(id) not found")
            return
        }

        if let audioData = copy.audioResource?.data {
            article.audioResource?.data = audioData
        }
        
        if let imageData = copy.imageResource?.data {
            article.imageResource?.data = imageData
        }

//        let actor = BackgroundSerialPersistenceActor(container: PersistentContainerManager.shared.container!)

//        Task {
            article.revisedTags.forEach { tag in
                Task {
//                    let predicate = #Predicate<ContextTag> { $0.id == tag.id }
//                    try await actor.remove(predicate: predicate)
                    await ContextTagManager.shared.delete(id: tag.id)
                }
            }
//        }

//        Task {
            article.revisedTimepoints.forEach { timepoint in
                Task {
                    await TimepointInformationManager.shared.delete(id: timepoint.id)
                }

//                Task {
//                    let predicate = #Predicate<TimepointInformation> { $0.id == timepoint.id }
//                    try await actor.remove(predicate: predicate)
//                }
            }
//        }

        article.revisedTimepoints = copy.revisedTimepoints.map { $0.toTimepointInformation() }
        article.revisedTags = copy.revisedTags.map { $0.toContextTag() }
        article.revisedText = copy.revisedText
        
        updates?(article)
        
        do {
            try context.save()
            print("Article with ID \(id) successfully updated")
        } catch {
            print("Failed to save updates for article with ID \(id): \(error)")
        }
    }
    
    // 更新記錄
    func updateAudio(id: String, audioData: Data?, with updates: ((PracticeTagArticle) -> Void)? = nil) {
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
    func updateImage(id: String, imageData: Data?, with updates: ((PracticeTagArticle) -> Void)? = nil) {
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
