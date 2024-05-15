//
//  DeckManager.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/5/10.
//

import Foundation

class DeckManager {
    
    static let shared = DeckManager()
    static let filename = "decks.json"
    
    var snapshot: [Deck] = []
    
    enum DataType {
        case card
        case deck
    }
    
    private init() {
        self.snapshot = DeckManager.readDeckFromFile(filename: DeckManager.filename) ?? []
    }
    
    static func read<T: Codable>(filename: String) -> [T]? {
        
        return nil
    }
    
    static func readDeckFromFile(filename: String) -> [Deck]? {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Failed to locate Documents directory")
            return nil
        }
        
        let fileURL = documentsDirectory.appendingPathComponent(filename)
        
        if let data = try? Data(contentsOf: fileURL),
           let decodedDecks = try? JSONDecoder().decode([Deck].self, from: data) {
            return decodedDecks
        } else {
            print("Error reading deck from file")
            return nil
        }
    }
    
    func add(_ deck: Deck) {
        snapshot.append(deck)
    }
    
    func remove(at index: Int) {
        snapshot.remove(at: index)
    }
    
    func writeToFile() {
        guard let url = getDocumentsDirectory() else { return }
        
        let fileURL = url.appendingPathComponent(DeckManager.filename)
        let encoder = JSONEncoder()
        
        if let encodedData = try? encoder.encode(snapshot) {
            do {
                try encodedData.write(to: fileURL)
            } catch {
                print("Error writing decks to file:", error.localizedDescription)
            }
        } else {
            print("Error encoding deck data")
        }
    }
    
    func getDocumentsDirectory() -> URL? {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Failed to locate Documents directory")
            return nil
        }
        
        return documentsDirectory
    }
    
    func createDefaultDeck() -> Deck {
        let newCard = Deck.NewCard(graduatingInterval: 1, easyInterval: 3, learningStpes: 1)
        let lapses = Deck.Lapses(relearningSteps: 1, leachThreshold: 2, minumumInterval: 1)
        let advanced = Deck.Advanced(startingEase: 2.5, easyBonus: 1.3)
        let master = Deck.Master(graduatingInterval: 730, consecutiveCorrects: 5)

        let deck = Deck(newCard: newCard, lapses: lapses, advanced: advanced, master: master, id: UUID().uuidString, cards: [], name: "")

        return deck
    }
}
