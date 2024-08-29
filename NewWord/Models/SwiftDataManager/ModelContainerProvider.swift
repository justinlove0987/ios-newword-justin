//
//  ModelContainerProvider.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/8/29.
//

import SwiftData

class ModelContainerProvider<Model: PersistentModel> {
    
    static func persistantContainer() -> ModelContainer? {
        let container = try? ModelContainer(
            for: Model.self,
            configurations: ModelConfiguration()
        )
        
        return container
    }
}
