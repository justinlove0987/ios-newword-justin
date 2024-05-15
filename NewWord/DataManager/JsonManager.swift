//
//  JsonManager.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/5/10.
//

import Foundation


class JsonManager {
    
    static func writeDeckToFile(deck: Deck, filename: String) {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Failed to locate Documents directory")
            return
        }
        
        let fileURL = documentsDirectory.appendingPathComponent(filename)
        
        var existingDecks: [Deck] = []
        
        if let data = try? Data(contentsOf: fileURL),
           let decodedDecks = try? JSONDecoder().decode([Deck].self, from: data) {
            existingDecks = decodedDecks
        }
        
        existingDecks.append(deck)
        
        if let encodedData = try? JSONEncoder().encode(existingDecks) {
            do {
                try encodedData.write(to: fileURL)
            } catch {
                print("Error writing deck to file:", error.localizedDescription)
            }
        } else {
            print("Error encoding deck data")
        }
    }
    
    static func readDeckFromFile(filename: String) -> [Deck]? {
        guard let url = getDocumentsDirectory() else { return nil }
        
        let fileURL = url.appendingPathComponent(filename)
        
        if let data = try? Data(contentsOf: fileURL),
           let decodedDecks = try? JSONDecoder().decode([Deck].self, from: data) {
            return decodedDecks
        } else {
            print("Error reading deck from file")
            return nil
        }
    }
    
    static func writeDeckArrayToFile(decks: [Deck], filename: String) {
        guard let url = getDocumentsDirectory() else { return }
        
        let fileURL = url.appendingPathComponent(filename)
        let encoder = JSONEncoder()
        
        if let encodedData = try? encoder.encode(decks) {
            do {
                try encodedData.write(to: fileURL)
            } catch {
                print("Error writing decks to file:", error.localizedDescription)
            }
        } else {
            print("Error encoding deck data")
        }
    }
    
    static func getDocumentsDirectory() -> URL? {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Failed to locate Documents directory")
            return nil
        }
        
        return documentsDirectory
    }
}
