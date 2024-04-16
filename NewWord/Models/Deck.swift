//
//  Deck.swift
//  NewWord
//
//  Created by justin on 2024/4/12.
//

import Foundation


struct Deck {
    let startingEase: Double
    let correctBonus: Double
}

extension Deck {
    static func createFakeDeck() -> Deck {
        let deck = Deck(startingEase: 2.5, correctBonus: 1.3)
        return deck
    }
}
