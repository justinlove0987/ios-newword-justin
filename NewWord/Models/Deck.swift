//
//  Deck.swift
//  NewWord
//
//  Created by justin on 2024/4/12.
//

import Foundation


struct Deck {
    struct NewCard {
        let graduatingInterval: Int
        let easyInterval: Int
    }
    
    struct Lapses {
        enum LeachAction {
            case tagOnly
            case suspendCard
            case moveToStrengthenArea

        }
        
        let relearningSteps: Double
        let leachThreshold: Int
        let leachAction: LeachAction = .moveToStrengthenArea
    }

    struct Advanced {
        let startingEase: Double
        let easyBonus: Double
    }

    let newCard: NewCard
    let lapses: Lapses
    let advanced: Advanced


}

extension Deck {
    static func createFakeDeck() -> Deck {
        let newCard = Deck.NewCard(graduatingInterval: 1, easyInterval: 3)

        let lapses = Deck.Lapses(relearningSteps: 1, leachThreshold: 2)

        let advanced = Deck.Advanced(startingEase: 2.5, easyBonus: 1.3)


        let deck = Deck(newCard: newCard, lapses: lapses, advanced: advanced)

        let d: TimeInterval = 13

        return deck
    }
}
