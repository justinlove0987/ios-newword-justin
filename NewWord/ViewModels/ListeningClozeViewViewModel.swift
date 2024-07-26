//
//  ListeningClozeViewViewModel.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/7/26.
//

import Foundation


struct ListeningClozeViewViewModel {
    var card: CDCard?
    
    
    func getOriginalText() -> String? {
        guard let card else { return nil }
        
        return CoreDataManager.shared.getClozeWord(from: card)
    }
    
    func getTranslatedText() -> String? {
        guard let card else { return nil }
        
        return CoreDataManager.shared.getHint(from: card)
    }
    
}
