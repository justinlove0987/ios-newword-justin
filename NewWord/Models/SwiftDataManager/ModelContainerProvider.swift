//
//  ModelContainerProvider.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/8/29.
//

import Foundation
import SwiftData

typealias ModelProtocol = PersistentModel & Identifiable

@MainActor
class ModelContainerProvider<Model: ModelProtocol> {
    
    var context = ModelContainerProvider.persistantContainer().mainContext
    
    static func persistantContainer() -> ModelContainer {
        let container = try? ModelContainer(
            for: Model.self,
            configurations: ModelConfiguration()
        )
        
        return container!
    }
    
    // 新增記錄
    func create(model: Model) {
        context.insert(model)
        
        do {
            // 保存上下文的更改
            try context.save()
        } catch {
            print("Failed to save rule: \(error)")
        }
    }
    
    // 刪除所有記錄
     func deleteAll() {
         do {
             let allModels = try context.fetch(FetchDescriptor<Model>())
             for model in allModels {
                 context.delete(model)
             }
             try context.save() // 保存上下文更改
         } catch {
             print("Failed to delete all models: \(error)")
         }
     }
    
    // 刪除記錄
    func delete(id: PersistentIdentifier) {
        if let rule = fetch(byId: id) {
            context.delete(rule)
            
            do {
                try context.save()
            } catch {
                print("Failed to delete rule: \(error)")
            }
        } else {
            print("Rule with ID \(id) not found")
        }
    }
    
    // 更新記錄
     func update(id: PersistentIdentifier, with updates: (Model) -> Void) {
         if let model = fetch(byId: id) {
             updates(model)
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
        let descriptor = FetchDescriptor<Model>(
            predicate: #Predicate { $0.persistentModelID == id }
        )
        
        do {
            let rules = try context.fetch(descriptor)
            
            return rules.first
            
        } catch {
            print("Failed to load rule model.")
            
            return nil
        }
    }
    
    // 讀取所有記錄
    func fetchAll() -> [Model] {
        
        do {
            let rules = try context.fetch(FetchDescriptor<Model>())
            
            return rules
        } catch {
            print("Failed to fetch rules: \(error)")
            return []
        }
    }
}
