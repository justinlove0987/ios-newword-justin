//
//  DeckManager.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/5/10.
//

import Foundation

class DeckManager: DataManager<Deck> {
    
    static let shared = DeckManager()

    private static let filename = "decks.json"
    
    private init() {
        super.init(filename: DeckManager.filename)
        self.snapshot = readFromFile() ?? []
    }
    
    func addCardTo(to deck: Deck, with cardId: String) {
        if let index = snapshot.firstIndex(where: { $0 == deck }) {
            snapshot[index].storedCardIds.append(cardId)
            writeToFile()
        } else {
            print("Deck with id \(deck) not found.")
        }
    }

    func deleteAllCards(_ deck: Deck) {
        if let index = snapshot.firstIndex(where: { $0 == deck }) {
            snapshot[index] = deck
            snapshot[index].storedCardIds.removeAll()
            writeToFile()
        } else {
            print("Deck with id \(deck) not found.")
        }
    }
}

extension DeckManager {
    func createDefaultDeck() -> Deck {
        let newCard = Deck.NewCard(graduatingInterval: 1, easyInterval: 3, learningStpes: 1)
        let lapses = Deck.Lapses(relearningSteps: 1, leachThreshold: 2, minumumInterval: 1)
        let advanced = Deck.Advanced(startingEase: 2.5, easyBonus: 1.3)
        let master = Deck.Master(graduatingInterval: 730, consecutiveCorrects: 5)

        let deck = Deck(newCard: newCard, lapses: lapses, advanced: advanced, master: master, id: UUID().uuidString, name: "", storedCardIds: [])

        return deck
    }
}
