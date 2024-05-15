//
//  DataManager.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/5/15.
//

import Foundation


class DataManager<T: Codable> {
    
    let filename: String
//    var snapshot: [T] = []
    
    init(filename: String) {
        self.filename = filename
    }
    
    static func shared(filename: String) -> DataManager {
        return DataManager(filename: filename)
    }
    
    func readFromFile(filename: String) -> [T]? {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Failed to locate Documents directory")
            return nil
        }
        
        let fileURL = documentsDirectory.appendingPathComponent(filename)
        
        let fileExists = FileManager.default.fileExists(atPath: fileURL.path)
        
        if fileExists {
            do {
                let data = try Data(contentsOf: fileURL)
                let decodedDecks = try JSONDecoder().decode([T].self, from: data)
                return decodedDecks
            } catch {
                print("Error reading card from file:", error)
                return nil
            }
        } else {
            let emptyDecks: [T] = []
            do {
                let encodedData = try JSONEncoder().encode(emptyDecks)
                try encodedData.write(to: fileURL)
                return emptyDecks
            } catch {
                print("Error creating file:", error)
                return nil
            }
        }
    }
    
//    func add(_ data: T) {
//        snapshot.append(data)
//    }
//    
//    func remove(at index: Int) {
//        snapshot.remove(at: index)
//    }
    
    func writeToFile(data: [T]) {
        
        guard let url = getDocumentsDirectory() else { return }
        
        let fileURL = url.appendingPathComponent(filename)
        let encoder = JSONEncoder()
        
        if let encodedData = try? encoder.encode(data) {
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
}
