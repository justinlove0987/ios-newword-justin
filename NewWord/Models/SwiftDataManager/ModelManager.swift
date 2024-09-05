//
//  ModelContainerProvider.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/8/29.
//

import Foundation
import SwiftData
import SwiftUI

// https://www.swiftyplace.com/blog/swiftdata-stack-understanding-containers

typealias ModelProtocol = PersistentModel & Identifiable

@MainActor
class ModelManager<Model: ModelProtocol> {
    
    var context: ModelContext? = PersistentContainerManager.shared.container?.mainContext

    // 新增記錄
    func create(model: Model) {
        guard let context = context else { return }
        context.insert(model)
        
        do {
            try context.save()
        } catch {
            print("Failed to save model: \(error)")
        }
    }
    
    // 刪除所有記錄
    func deleteAll() {
        guard let context = context else { return }
        do {
            let allModels = try context.fetch(FetchDescriptor<Model>())
            for model in allModels {
                context.delete(model)
            }
            try context.save()
        } catch {
            print("Failed to delete all models: \(error)")
        }
    }
    
    func deleteAll<T: PersistentModel>(ofType modelType: T.Type) {
        do {
            let allModels = try context?.fetch(FetchDescriptor<T>()) // 使用模型類型創建 FetchDescriptor
            
            guard let allModels else { return }
            
            for model in allModels {
                context?.delete(model)
            }
            
            try context?.save()
            print("Successfully deleted all models of type \(modelType)")
        } catch {
            print("Failed to delete all models of type \(modelType): \(error)")
        }
    }
    
    // 刪除記錄
    func delete(id: PersistentIdentifier) {
        guard let context = context else { return }
        if let model = fetch(byId: id) {
            context.delete(model)
            do {
                try context.save()
            } catch {
                print("Failed to delete model: \(error)")
            }
        } else {
            print("Model with ID \(id) not found")
        }
    }
    
    // 更新記錄
    func update(id: PersistentIdentifier, with updates: ((Model) -> Void)? = nil) {
        guard let context = context else { return }

        if let model = fetch(byId: id) {
            // 如果有傳遞 updates 閉包，則執行更新
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

    // 讀取記錄
    func fetch(byId id: PersistentIdentifier) -> Model? {
        guard let context = context else { return nil }
        let descriptor = FetchDescriptor<Model>(
            predicate: #Predicate { $0.persistentModelID == id }
        )
        
        do {
            let models = try context.fetch(descriptor)
            return models.first
        } catch {
            print("Failed to load model.")
            return nil
        }
    }
    
    // 讀取所有記錄
    func fetchAll() -> [Model] {
        guard let context = context else { return [] }
        do {
            let models = try context.fetch(FetchDescriptor<Model>())
            return models
        } catch {
            print("Failed to fetch models: \(error)")
            return []
        }
    }
    
    func deleteAllEntities() {
        for model in PersistentContainerManager.shared.models {
            deleteAll(ofType: model)
        }
    }

    // 保存當前狀態
    func save() {
        guard let context = context else { return }

        do {
            try context.save()
            print("Successfully saved the context.")
        } catch {
            print("Failed to save the context: \(error)")
        }
    }

}

class PersistentContainerManager {

    static let shared = PersistentContainerManager()
    
    let models: [any PersistentModel.Type] = [
        DefaultPracticePreset.self,
        Article.self,
        PracticeAudio.self,
        PracticeImage.self,
        PracticeThresholdRule.self,
        PracticePreset.self,
        PracticeMap.self,
        PracticeServerProvidedContent.self,
        Practice.self,
    ]

    let container: ModelContainer?

    init() {
        let schema = Schema(models)

        let configuration = ModelConfiguration(isStoredInMemoryOnly: false)

        container = try? ModelContainer(for: schema, configurations: [configuration])
    }
}
