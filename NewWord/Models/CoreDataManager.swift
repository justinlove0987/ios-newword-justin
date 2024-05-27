//
//  CoreDataManager.swift
//  NewWord
//
//  Created by justin on 2024/5/27.
//

import Foundation
import CoreData


class CoreDataManager {

    static let shared = CoreDataManager()

    let persistentContainer: NSPersistentContainer

    private init() {

        persistentContainer = NSPersistentContainer(name: "Model")
        persistentContainer.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Core Data Sotre failed to initialize \(error.localizedDescription)")
            }
        }
    }


//    func getAllMovies() -> [Movie] {
//        let fetchReqeust: NSFetchRequest<Movie> = Movie.fetchRequest()
//
//        do {
//            return try persistentContainer.viewContext.fetch(fetchReqeust)
//        } catch {
//            return []
//        }
//    }
//
//    func saveMove(title: String) {
//        let movie = Movie(context: persistentContainer.viewContext)
//
//        movie.title = title
//
//        do {
//            try persistentContainer.viewContext.save()
//            print("Movie saved!")
//        } catch {
//            print("Failed to save movie \(error)")
//        }
//
//    }
//
//
//    func addRoom(with color: UIColor) {
//        let room = Room(context: persistentContainer.viewContext)
//        room.color = color
//        save()
//    }
//
//    func getRooms() -> [Room] {
//        let fetchRequest = Room.fetchRequest()
//
//        do {
//            return try persistentContainer.viewContext.fetch(fetchRequest)
//        } catch {
//            return []
//        }
//
//    }
//
//    func deleteAllRooms() {
//
//        let fetchRequest = Room.fetchRequest()
//        let context = persistentContainer.viewContext
//
//        do {
//            let rooms = try context.fetch(fetchRequest)
//
//            for room in rooms {
//                context.delete(room)
//            }
//
//            save()
//
//        } catch {
//            print("error: \(error.localizedDescription)")
//        }
//    }

    func save() {
        do {
            try persistentContainer.viewContext.save()
        } catch {
            persistentContainer.viewContext.rollback()
            print("Failed to save movie!")
        }
    }

}

extension CoreDataManager {
    func getDecks() -> [CDDeck] {
        let fetchReqeust: NSFetchRequest<CDDeck> = CDDeck.fetchRequest()

        do {
            return try persistentContainer.viewContext.fetch(fetchReqeust)
        } catch {
            return []
        }
    }

    func addDeck(name: String) {
        let deck = CDDeck(context: persistentContainer.viewContext)
        deck.name = name

        save()
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
