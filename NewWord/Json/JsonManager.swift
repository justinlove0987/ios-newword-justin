//
//  JsonManager.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/5/10.
//

import Foundation


class JsonManager {
    
    static func writeDeckToFile(deck: Deck, filename: String) {
        // Get the URL for the Documents directory
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Failed to locate Documents directory")
            return
        }
        
        // Append the filename to the Documents directory URL
        let fileURL = documentsDirectory.appendingPathComponent(filename)
        
        // Load existing JSON data from file, if any
        var existingDecks: [Deck] = []
        if let data = try? Data(contentsOf: fileURL),
           let decodedDecks = try? JSONDecoder().decode([Deck].self, from: data) {
            existingDecks = decodedDecks
        }
        
        // Append the new deck to the existing array
        existingDecks.append(deck)
        
        // Encode the array of decks into JSON data
        if let encodedData = try? JSONEncoder().encode(existingDecks) {
            // Write the encoded data to the file
            do {
                try encodedData.write(to: fileURL)
                print("Deck has been successfully written to \(fileURL.path)")
            } catch {
                print("Error writing deck to file:", error.localizedDescription)
            }
        } else {
            print("Error encoding deck data")
        }
    }
}
