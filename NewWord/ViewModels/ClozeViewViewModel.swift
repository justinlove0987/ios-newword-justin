//
//  ClozeViewViewModel.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/6/9.
//

import Foundation

struct ClozeViewViewModel {
    
    private var card: CDCard
    
    init(card: CDCard) {
        self.card = card
    }
    
    func getContextText() -> String? {
        guard let cloze = card.note?.noteType?.cloze else { return nil }
        guard let text = cloze.contextText?.text else { return nil }
        guard let id = cloze.id else { return nil }
        
        let newText = text.replacingOccurrences(of: "\\{\\{C\(id):\\w+\\}\\}", with: "[...]", options: .regularExpression)
        
        return newText
    }
    
}
