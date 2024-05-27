//
//  CardManager.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/5/15.
//

import Foundation

class CardManager: DataManager<Card> {
    
    static let shared = CardManager()
    
    private static let filename = "cards.json"
    
    private init() {
        super.init(filename: CardManager.filename)
        self.snapshot = readFromFile() ?? []
    }

}
