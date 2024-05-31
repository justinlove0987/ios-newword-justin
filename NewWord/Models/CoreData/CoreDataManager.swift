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
            print("Failed to save data!")
        }
    }

}


// MARK: - Deck

extension CoreDataManager {

    func getDecks() -> [CDDeck] {
        let fetchReqeust: NSFetchRequest<CDDeck> = CDDeck.fetchRequest()

        do {
            let decks = try persistentContainer.viewContext.fetch(fetchReqeust)
            return decks
        } catch {
            return []
        }
    }
    
    func addDeck(name: String, preset: CDPreset) {
        let deck = CDDeck(context: persistentContainer.viewContext)
        deck.name = name

        save()
    }
    
    @discardableResult
    func addDeck(name: String) -> CDDeck {
        let deck = CDDeck(context: persistentContainer.viewContext)
        deck.name = name
        deck.id = UUID().uuidString
        deck.preset = createDefaultPreset()
        
        save()

        return deck
    }
    
    func deleteDeck(_ deck: CDDeck) {
        persistentContainer.viewContext.delete(deck)
        
        save()
    }
    
    func updateDeckName(_ deck: CDDeck, _ name: String) {
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

    
}

// MARK: - Card

extension CoreDataManager {
    func createEmptyCard() -> CDCard {
        let card = CDCard(context: persistentContainer.viewContext)
        return card
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

// MARK: - LearningRecord

extension CoreDataManager {
    func createLearningRecord(dueDate: Date, ease: Double, learnedDate: Date, stateRawValue: String, statusRawValue: String) -> CDLearningRecord {
        let learningRecord = CDLearningRecord(context: persistentContainer.viewContext)
        
        learningRecord.dueDate = dueDate
        learningRecord.ease = ease
        learningRecord.learnedDate = learnedDate
        learningRecord.stateRawValue = stateRawValue
        learningRecord.statusRawValue = statusRawValue
        
        return learningRecord
    }
    
    
    
    func createLearningRecord(lastCard: CDCard, deck: CDDeck, isAnswerCorrect: Bool) -> CDLearningRecord {
        let today: Date = Date()

        // TODO: - 在新增learningRecord時增加說明
        // TODO: - 調整 latestReview ease
        // TODO: - 將答錯時，ease需要加上的趴數獨立出來
        // TODO: - 需要調整 ease
        // TODO: - 修改 dueDate 應該是 today 加上 computed interval

        guard let latestLearningRecord = lastCard.latestLearningRecord else {
            let newCard = deck.preset!.newCard!
            
            let dueDate: Date = isAnswerCorrect ? addInterval(to: today, dayInterval: Int(newCard.easyInterval))! : addInterval(to: today, secondInterval: newCard.learningStpes)
            let statusRawValue = isAnswerCorrect ? CDLearningRecord.Status.correct.rawValue : CDLearningRecord.Status.incorrect.rawValue
            
            let learningRecord = createLearningRecord(dueDate: dueDate, ease: 2.5, learnedDate: today, stateRawValue: statusRawValue, statusRawValue: CDLearningRecord.State.learn.rawValue)
            
            return learningRecord
        }
        
        let lastStatus =  latestLearningRecord.status
        let lastState = latestLearningRecord.state
        
        let dueDate: Date
        let newStatus: CDLearningRecord.Status
        let newState: CDLearningRecord.State
        
        if isAnswerCorrect {
            newStatus = .correct
            
            if lastCard.isMasterCard(belongs: deck) {
                let newInterval = latestLearningRecord.interval * (latestLearningRecord.ease + 0.2)
                dueDate = today.addingTimeInterval(newInterval)
                newState = .master
                
            } else {
                switch (lastState, lastStatus) {
                case (.learn, .correct), (.review, .correct), (.relearn, .correct):
                    let newInterval = latestLearningRecord.interval * (latestLearningRecord.ease + 0.2)
                    dueDate = today.addingTimeInterval(newInterval)
                    newState = .review
                case (.learn, .incorrect):
                    let interval = deck.preset!.newCard!.graduatingInterval
                    dueDate = addInterval(to: today, dayInterval: Int(interval))!
                    newState = .learn
                case (.review, .incorrect), (.relearn, .incorrect):
                    let newInterval = 1
                    dueDate = addInterval(to: today, dayInterval: newInterval)!
                    newState = .relearn
                default:
                    fatalError("Unknown state!")
                }
            }
            
        } else {
            newStatus = .incorrect
            
            if lastCard.isLeachCard(belongs: deck) {
                dueDate = today
                newState = .leach
                
            } else {
                switch (lastState, lastStatus) {
                case (.learn, .correct), (.review, .correct), (.relearn, .correct):
                    let relearningStpes = deck.preset!.lapses!.relearningSteps
                    dueDate = addInterval(to: today, secondInterval: relearningStpes)
                    newState = .review
                    
                case (.learn, .incorrect):
                    let interval = deck.preset!.lapses!.relearningSteps
                    dueDate = addInterval(to: today, secondInterval: interval)
                    newState = .learn
                    
                case (.review, .incorrect), (.relearn, .incorrect):
                    let interval = deck.preset!.lapses!.relearningSteps
                    dueDate = addInterval(to: today, secondInterval: interval)
                    newState = .relearn
                    
                default:
                    fatalError("Unknown state!")
                }
            }
        }

        return createLearningRecord(dueDate: dueDate, ease: 2.5, learnedDate: today, stateRawValue: newState.rawValue, statusRawValue: newStatus.rawValue)
    }
}

// MARK: - Preset

extension CoreDataManager {

    func addNewCard(graduatingInterval: Int, easyInterval: Int, learningStpes: Double) -> CDNewCard {

        let newCard = CDNewCard(context: persistentContainer.viewContext)

        newCard.graduatingInterval = Int64(graduatingInterval)
        newCard.easyInterval = Int64(easyInterval)
        newCard.learningStpes = learningStpes

        return newCard
    }
    
    func addLapses(relearningSteps: Double, leachThreshold: Int, minumumInterval: Int) -> CDLapses {
        let lapses = CDLapses(context: persistentContainer.viewContext)
        
        lapses.relearningSteps = relearningSteps
        lapses.leachThreshold = Int64(leachThreshold)
        lapses.minumumInterval = Int64(minumumInterval)
        
        return lapses
        
    }
    
    func addMaster(graduatingInterval: Int, consecutiveCorrects: Int) -> CDMaster {
        let master = CDMaster(context: persistentContainer.viewContext)
        
        master.graduatingInterval = Int64(graduatingInterval)
        master.consecutiveCorrects = Int64(consecutiveCorrects)
        
        return master
    }
    
    func addAdvanced(startingEase: Double, easyBonus: Double) -> CDAdvanced {
        let advanced = CDAdvanced(context: persistentContainer.viewContext)
        
        advanced.startingEase = startingEase
        advanced.easyBonus = easyBonus
        
        return advanced
    }

    func createDefaultPreset() -> CDPreset {
        let preset = CDPreset(context: persistentContainer.viewContext)

        let newCard = addNewCard(graduatingInterval: 1, easyInterval: 3, learningStpes: 1)
        let lapses = addLapses(relearningSteps: 1, leachThreshold: 2, minumumInterval: 1)
        let advanced = addAdvanced(startingEase: 2.5, easyBonus: 1.3)
        let master = addMaster(graduatingInterval: 730, consecutiveCorrects: 5)
        
        preset.newCard = newCard
        preset.lapses = lapses
        preset.advanced = advanced
        preset.master = master
        
        return preset
    }
}

// MARK: - Sentence

extension CoreDataManager {
    func words(from sentence: CDSentence) -> [CDWord] {
        let request: NSFetchRequest<CDWord> = CDWord.fetchRequest()
        request.predicate = NSPredicate(format: "sentence = %@", sentence)
        var fetched: [CDWord] = []
        do {
            fetched = try persistentContainer.viewContext.fetch(request)
        } catch let error {
            print("Error fetching songs \(error)")
        }
        return fetched
    }
}

// MARK: - Helpers

extension CoreDataManager {
    func addInterval(to date: Date, dayInterval: Int) -> Date? {
        let interval: Int = dayInterval

        var dateComponents = DateComponents()
        dateComponents.day = interval

        let calendar = Calendar.current
        let futureDate = calendar.date(byAdding: dateComponents, to: date)

        return futureDate
    }

    func addInterval(to date: Date, secondInterval: Double) -> Date {
        return date.addingTimeInterval(secondInterval)
    }
}
