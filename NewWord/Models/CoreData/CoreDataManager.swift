//
//  CoreDataManager.swift
//  NewWord
//
//  Created by justin on 2024/5/31.
//

import Foundation

import CoreData

class CoreDataManager {

    static let shared = CoreDataManager()

    let persistentContainer: NSPersistentContainer

    private init() {

        persistentContainer = NSPersistentContainer(name: "DataModel")
        persistentContainer.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Core Data Sotre failed to initialize \(error.localizedDescription)")
            }
        }
    }

    func save() {
        do {
            try persistentContainer.viewContext.save()
        } catch {
            persistentContainer.viewContext.rollback()
            print("Failed to save movie!")
        }
    }

}


// MARK: - Deck

extension CoreDataManager {

    func getDecks() -> [CDDeck] {
        let fetchReqeust: NSFetchRequest<CDDeck> = CDDeck.fetchRequest()

        do {
            return try persistentContainer.viewContext.fetch(fetchReqeust)
        } catch {
            return []
        }
    }
    
    @discardableResult
    func addDeck(name: String) -> CDDeck {
        let deck = CDDeck(context: persistentContainer.viewContext)
        deck.name = name

        save()

        return deck
    }


    func deckExists() -> Bool {
        let fetchRequest: NSFetchRequest<CDDeck> = CDDeck.fetchRequest()

        do {
            let count = try persistentContainer.viewContext.count(for: fetchRequest)
            return count > 0
        } catch {
            print("Failed to fetch deck: \(error)")
            return false
        }
    }


    func cards(from deck: CDDeck) -> [CDCard] {
        let request: NSFetchRequest<CDCard> = CDCard.fetchRequest()
        request.predicate = NSPredicate(format: "deck = %@", deck)
        var fetched: [CDCard] = []
        do {
            fetched = try persistentContainer.viewContext.fetch(request)
        } catch let error {
            print("Error fetching songs \(error)")
        }
        return fetched
    }

    func learningRecords(from card: CDCard) -> [CDLearningRecord] {
        let request: NSFetchRequest<CDLearningRecord> = CDLearningRecord.fetchRequest()
        request.predicate = NSPredicate(format: "card = %@", card)

        var fetched: [CDLearningRecord] = []

        do {
            fetched = try persistentContainer.viewContext.fetch(request)
        } catch let error {
            print("Error fetching songs \(error)")
        }
        return fetched
    }
}

// MARK: - Preset

extension CoreDataManager {

    func addPreset(advanced: CDAdvanced, lapses: CDLapses, master: CDMaster) {
        let preset = CDPreset(context: persistentContainer.viewContext)

        save()
    }

    func addNewCard(graduatingInterval: Int, easyInterval: Int, learningStpes: Double) -> CDNewCard {

        let newCard = CDNewCard(context: persistentContainer.viewContext)

        newCard.graduatingInterval = Int64(graduatingInterval)
        newCard.easyInterval = Int64(easyInterval)
        newCard.learningStpes = learningStpes

        return newCard
    }

    func createDefaultPreset() -> CDPreset {
        let preset = CDPreset(context: persistentContainer.viewContext)

        let newCard = addNewCard(graduatingInterval: 1, easyInterval: 3, learningStpes: 1)

        
        return preset
    }


}
