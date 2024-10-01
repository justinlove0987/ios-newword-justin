//
//  CoreDataManager.swift
//  NewWord
//
//  Created by justin on 2024/5/31.
//

import Foundation

import CoreData
import UIKit

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
            print(error)
            persistentContainer.viewContext.rollback()
            print("Failed to save data!")
        }
    }

    func deleteAllEntities() {

        let context = persistentContainer.viewContext
        // 獲取所有實體描述
        guard let persistentStoreCoordinator = context.persistentStoreCoordinator else { return }
        let entities = persistentStoreCoordinator.managedObjectModel.entities

        for entity in entities {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity.name!)
            fetchRequest.includesPropertyValues = true // 我們只需要對象的引用來刪除它們

            do {
                if let objects = try context.fetch(fetchRequest) as? [NSManagedObject] {
                    for object in objects {
                        context.delete(object)
                    }
                }
            } catch {
                print("刪除實體 \(entity.name!) 時出錯：\(error)")
            }
        }

        do {
            try context.save()
        } catch {
            print("保存上下文時出錯：\(error)")
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
    
    /// 自動新增 default preset
    @discardableResult
    func addDeck(name: String) -> CDDeck {
        let deck = CDDeck(context: persistentContainer.viewContext)
        deck.name = name
        deck.id = UUID().uuidString
        deck.preset = createDefaultPreset()
        
        save()

        return deck
    }
    
    func getNewCards(from deck: CDDeck) -> [CDCard] {
        let cards = cards(from: deck)
        
        let newCards = cards.filter { card in
            let learningRecords = CoreDataManager.shared.learningRecords(from: card)
            return learningRecords.isEmpty
        }
        
        return newCards
    }
    
    func getReviewCards(from deck: CDDeck) -> [CDCard] {
        let cards = cards(from: deck)
        
        let reviewCards = cards.filter { card in
            guard let review = card.latestLearningRecord else { return false }
            return (review.dueDate! <= Date() &&
                    review.status == .correct &&
                    (review.state == .learn || review.state == .review))
        }
        
        return reviewCards
    }
    
    func getRelearnCards(from deck: CDDeck) -> [CDCard] {
        let cards = cards(from: deck)
        
        let relearnCards = cards.filter { card in
            guard let record = card.latestLearningRecord else { return false }
            return (record.dueDate! <= Date() &&
                    record.status == .incorrect &&
                    (record.state == .relearn ||
                     record.state == .learn ||
                     record.state == .relearn))
        }
        
        return relearnCards
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

    func addCard(to deck: CDDeck, with note: CDNote) {
        let card = createCard(note: note)
        card.deck = deck

        save()
    }
    
    func findFirstDeckWithCard() -> CDDeck? {
        let fetchReqeust: NSFetchRequest<CDDeck> = CDDeck.fetchRequest()

        do {
            let decks = try persistentContainer.viewContext.fetch(fetchReqeust)
            
            for deck in decks {
                let cards = cards(from: deck)
                
                if !cards.isEmpty {
                    return deck
                }
            }
            
            return nil
            
        } catch {
            return nil
        }
    }

    
}

// MARK: - Card

extension CoreDataManager {
    func getCards() -> [CDCard] {
        let fetchReqeust: NSFetchRequest<CDCard> = CDCard.fetchRequest()

        do {
            let decks = try persistentContainer.viewContext.fetch(fetchReqeust)
            return decks
        } catch {
            return []
        }
    }
    
    
    func createCard(note: CDNote) -> CDCard {
        let card = CDCard(context: persistentContainer.viewContext)
        
        card.id = UUID().uuidString
        card.addedDate = Date()
        card.note = note

        return card
    }

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

    func addLearningReocrd(_ learningReocrd: CDLearningRecord, to card: CDCard) {
        learningReocrd.card = card

        save()
    }
}

// MARK: - Note

extension CoreDataManager {
    func createNote(typeRawValue: Int) -> CDNote {
        let note = CDNote(context: persistentContainer.viewContext)

        note.id = UUID().uuidString
        note.typeRawValue = Int64(typeRawValue)

        return note
    }

    func creaetFakeSentenceCloze() -> [CDNote] {
        let sentences = [
            ["Life", "is", "like", "riding", "a", "bicycle", ".", "To", "keep", "your", "balance", ",", "you", "must", "keep", "moving", "."],
            ["Genius", "is", "one", "percent", "inspiration", "and", "ninety-nine", "percent", "perspiration", "."]
        ]

        _ = CoreDataManager.shared.createWord(chinese: "像是我", text: "like")
        let words1 = CoreDataManager.shared.createWords(words: sentences[0])

        _ = CoreDataManager.shared.createSentence(words: words1)
//        let sentenceCloze1 = CoreDataManager.shared.createSentenceCloze(clozeword: clozeword1, sentence: sentence1)

        let note = CoreDataManager.shared.createNote(typeRawValue: NoteType.sentenceCloze.rawValue)

        return [note]
    }
    
    func createFakeCloze() -> [CDNote] {

        let cloze = createCloze(number: 1, hint: "", clozeWord: "")
        let text = "The mass movement for Palestine returned to Washington, DC on Sat., June 8—forming a two-mile-long “red line” around the White House with a crowd that {{C\(cloze.id!):numbered}} in the tens of thousands. As discussed in a prior interview with The Real News, organizers of “The People’s Red Line” are seeking an immediate, permanent end to US aid to Israel. Jaisal Noor reports for TRNN from the streets of DC.The mass movement for Palestine returned to Washington, DC on Sat., June 8—forming a two-mile-long “red line” around the White House with a crowd that numbered in the tens of thousands. As discussed in a prior interview with The Real News, organizers of “The People’s Red Line” are seeking an immediate, permanent end to US aid to Israel. Jaisal Noor reports for TRNN from the streets of DC.The mass movement for Palestine returned to Washington, DC on Sat., June 8—forming a two-mile-long “red line” around the White House with a crowd that numbered in the tens of thousands. As discussed in a prior interview with The Real News, organizers of “The People’s Red Line” are seeking an immediate, permanent end to US aid to Israel. Jaisal Noor reports for TRNN from the streets of DC.The mass movement for Palestine returned to Washington, DC on Sat., June 8—forming a two-mile-long “red line” around the White House with a crowd that numbered in the tens of thousands. As discussed in a prior interview with The Real News, organizers of “The People’s Red Line” are seeking an immediate, permanent end to US aid to Israel. Jaisal Noor reports for TRNN from the streets of DC.The mass movement for Palestine returned to Washington, DC on Sat., June 8—forming a two-mile-long “red line” around the White House with a crowd that numbered in the tens of thousands. As discussed in a prior interview with The Real News, organizers of “The People’s Red Line” are seeking an immediate, permanent end to US aid to Israel. Jaisal Noor reports for TRNN from the streets of DC.The mass movement for Palestine returned to Washington, DC on Sat., June 8—forming a two-mile-long “red line” around the White House with a crowd that numbered in the tens of thousands. As discussed in a prior interview with The Real News, organizers of “The People’s Red Line” are seeking an immediate, permanent end to US aid to Israel. Jaisal Noor reports for TRNN from the streets of DC."

        let context = createContext(text)

        cloze.contextId = context.id
        cloze.context = context

        let note = CoreDataManager.shared.createNote(typeRawValue: NoteType.cloze.rawValue)
        
        return [note]
    }
}


// MARK: - NoteResource

extension CoreDataManager {
    
    func createNoteResource() -> CDNoteResource {
        let resource = CDNoteResource(context: persistentContainer.viewContext)
        return resource
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
            let startCard = deck.preset!.startCard!
            
            let dueDate: Date = isAnswerCorrect ? addInterval(to: today, dayInterval: Int(startCard.easyInterval))! : addInterval(to: today, secondInterval: startCard.learningStpes)
            let statusRawValue = isAnswerCorrect ? CDLearningRecord.Status.correct.rawValue : CDLearningRecord.Status.incorrect.rawValue
            
            let learningRecord = createLearningRecord(dueDate: dueDate, ease: 2.5, learnedDate: today, stateRawValue: CDLearningRecord.State.learn.rawValue, statusRawValue: statusRawValue)
            
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
                    let interval = deck.preset!.startCard!.graduatingInterval
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

    func addStartCard(graduatingInterval: Int, easyInterval: Int, learningStpes: Double) -> CDStartCard {
        let startCard = CDStartCard(context: persistentContainer.viewContext)

        startCard.graduatingInterval = Int64(graduatingInterval)
        startCard.easyInterval = Int64(easyInterval)
        startCard.learningStpes = learningStpes

        return startCard
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

        let startCard = addStartCard(graduatingInterval: 1, easyInterval: 3, learningStpes: 1)
        let lapses = addLapses(relearningSteps: 1, leachThreshold: 2, minumumInterval: 1)
        let advanced = addAdvanced(startingEase: 2.5, easyBonus: 1.3)
        let master = addMaster(graduatingInterval: 730, consecutiveCorrects: 5)
        
        preset.startCard = startCard
        preset.lapses = lapses
        preset.advanced = advanced
        preset.master = master

        return preset
    }
}

// MARK: - Sentence

extension CoreDataManager {

    func createSentence(words: [CDWord]) -> CDSentence {
        let sentence = CDSentence(context: persistentContainer.viewContext)

        for word in words {
            word.sentence = sentence
        }

        return sentence
    }

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

// MARK: Word

extension CoreDataManager {
    func createWord(chinese: String, text: String) -> CDWord {
        let word = CDWord(context: persistentContainer.viewContext)

        word.chinese = chinese
        word.text = text

        return word
    }

    func createWords(words: [String]) -> [CDWord] {
        var cdWords: [CDWord] = []

        for word in words {
            let cdWord = createWord(chinese: "", text: word)
            cdWords.append(cdWord)
        }

        return cdWords
    }
}

// MARK: - Cloze

extension CoreDataManager {
    func createCloze(number: Int, hint: String, clozeWord: String) -> CDCloze {
        let cloze = CDCloze(context: persistentContainer.viewContext)
        
        cloze.id = UUID().uuidString
        cloze.number = Int64(number)
        cloze.clozeWord = clozeWord
        cloze.hint = hint

        return cloze
    }
    
    func createContext(_ text: String) -> CDClozeContext {
        let context = CDClozeContext(context: persistentContainer.viewContext)
        
        context.id = UUID().uuidString
        context.text = text

        return context
    }

    func getContext(from card: CDCard) -> String? {
        guard let text = card.note?.resource?.cloze?.context?.text else { return nil }

        return text
    }

    func getClozeNumber(from card: CDCard) -> Int? {
        guard let number = card.note?.resource?.cloze?.number else { return nil }

        return Int(number)
    }
    
    func getClozeWord(from card: CDCard) -> String? {
        guard let word = card.note?.resource?.cloze?.clozeWord else { return nil }

        return word
    }
    
    func getHint(from card: CDCard) -> String? {
        guard let word = card.note?.resource?.cloze?.hint else { return nil }

        return word
    }
    
    func getCloze(from card: CDCard) -> CDCloze? {
        return card.note?.resource?.cloze
    }
}

// MARK: - SelectableItemList

extension CoreDataManager {
    
    enum SelectableItemListType: String {
        case deck
    }

    func updateSelected(from id: String, type: SelectableItemListType, isSelected: Bool) {
        let fetchRequest: NSFetchRequest<CDSelectableItem> = CDSelectableItem.fetchRequest()

        // 創建謂詞，查找匹配的 SelectableItemList 類型和 relatedId
        let listPredicate = NSPredicate(format: "list.type == %@", type.rawValue)
        let relatedIdPredicate = NSPredicate(format: "relatedId == %@", id)

        // 將謂詞結合起來
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [listPredicate, relatedIdPredicate])
        fetchRequest.predicate = compoundPredicate

        do {
            // 執行請求
            let items = try persistentContainer.viewContext.fetch(fetchRequest)

            // 檢查是否有匹配的項目
            if let item = items.first {
                // 更新 isSelected 值
                item.isSelected = isSelected

                // 儲存上下文
                try persistentContainer.viewContext.save()
            }
        } catch {
            print("Update error: \(error)")
        }
    }

    func isSelected(from id: String, type: SelectableItemListType) -> Bool {
        let fetchRequest: NSFetchRequest<CDSelectableItem> = CDSelectableItem.fetchRequest()
        
        // 創建謂詞，查找匹配的 SelectableItemList 類型和 relatedId
        let listPredicate = NSPredicate(format: "list.type == %@", type.rawValue)
        let relatedIdPredicate = NSPredicate(format: "relatedId == %@", id)
        
        // 將謂詞結合起來
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [listPredicate, relatedIdPredicate])
        fetchRequest.predicate = compoundPredicate
        
        do {
            // 執行請求
            let items = try persistentContainer.viewContext.fetch(fetchRequest)
            
            // 檢查是否有匹配的項目，並返回 isSelected 狀態
            if let item = items.first {
                return item.isSelected
            }
        } catch {
            print("Fetch error: \(error)")
        }
        
        return false
    }
    
    func createSelectableItem(from relatedId: String) -> CDSelectableItem {
        let item = CDSelectableItem(context: persistentContainer.viewContext)
        
        item.relatedId = relatedId
        item.isSelected = true
        
        return item
    }
    
    func addSelectableItemList(items: [CDSelectableItem], type: SelectableItemListType) {
        let list = CDSelectableItemList(context: persistentContainer.viewContext)
        list.id = UUID().uuidString
        list.type = SelectableItemListType.deck.rawValue
        
        for item in items {
            item.list = list
        }
        
        save()
    }
    
//    func getD
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

// MARK: - CDPracticeTagArticle

extension CoreDataManager {

    func getUserGeneratedTimepoints(from article: CDPracticeArticle?) -> [CDTimepointInformation] {
//        if let timepoints = article?.userGeneratedArticle?.userGeneratedTimepoints?.allObjects as? [CDTimepointInformation] {
//            return timepoints
//        } else {
//            return []
//        }
        
        return []
    }
}



extension CoreDataManager {
    
    func createEntity<T: NSManagedObject>(ofType type: T.Type) -> T {
        let entity = T(context: persistentContainer.viewContext)

        return entity
    }

    func getAll<T: NSManagedObject>(ofType type: T.Type) -> [T] {
        let fetchRequest = T.fetchRequest()

        do {
            let fetchedEntities = try persistentContainer.viewContext.fetch(fetchRequest) as? [T]
            return fetchedEntities ?? []
        } catch {
            print("Failed to fetch \(T.self): \(error)")
            return []
        }
    }

    func deleteEntity<T: NSManagedObject>(_ entity: T) {
        persistentContainer.viewContext.delete(entity)

        do {
            try persistentContainer.viewContext.save()
            print("\(T.self) deleted successfully!")
        } catch {
            print("Failed to delete \(T.self): \(error)")
        }
    }

    func discardEntity<T: NSManagedObject>(_ entity: T) {
        persistentContainer.viewContext.delete(entity)
        print("\(T.self) discarded from context!")
    }

    func deleteAllEntities<T: NSManagedObject>(ofType type: T.Type) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: type))
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try persistentContainer.viewContext.execute(deleteRequest)
            try persistentContainer.viewContext.save()
            print("All \(T.self) entities deleted successfully!")
        } catch {
            print("Failed to delete all \(T.self) entities: \(error)")
        }
    }

}

// MARK: - CDPracticeMap

extension CoreDataManager {
    
    func getFirstBlueprintMap() -> CDPracticeMap? {
        let fetchRequest: NSFetchRequest<CDPracticeMap> = CDPracticeMap.fetchRequest()
        
        // 過濾條件: typeRawValue 等於 PracticeMapType.blueprint 的 rawValue
        fetchRequest.predicate = NSPredicate(format: "typeRawValue == %d", PracticeMapType.blueprintForArticleWord.rawValue)
        
        // 只需要第一個結果
        fetchRequest.fetchLimit = 1
        
        do {
            let results = try persistentContainer.viewContext.fetch(fetchRequest)
            return results.first
        } catch {
            print("Failed to fetch blueprint map: \(error)")
            return nil
        }
    }
    
    func hasPracticeMap() -> Bool {
        let practiceMaps = CoreDataManager.shared.getAll(ofType: CDPracticeMap.self)
        
        return practiceMaps.count > 0
    }
    
    func createPracticeMapBlueprint() {
        for practiceMapType in PracticeMapType.allCases {
            guard practiceMapType != .practice else {
                continue
            }
            
            guard let practiceMapBlueprint = practiceMapType.practiceBlueprint else {
                continue
            }
            
            let map = CoreDataManager.shared.createEntity(ofType: CDPracticeMap.self)
            
            map.typeRawValue = practiceMapType.rawValue.toInt64
            
            for i in 0..<practiceMapBlueprint.count {
                let sequenceBluprint = practiceMapBlueprint[i]
                let sequence = CoreDataManager.shared.createEntity(ofType: CDPracticeSequence.self)
                
                sequence.map = map
                
                for j in 0..<sequenceBluprint.count {
                    let practiceBlueprint = sequenceBluprint[j]
                    let practice = CoreDataManager.shared.createEntity(ofType: CDPractice.self)
                    
                    practice.order = j.toInt64
                    practice.typeRawValue = practiceBlueprint.rawValue.toInt64
                    practice.sequence = sequence
                    
                }
            }
        }
        
        CoreDataManager.shared.save()
    }
}

// MARK: CDPractice

extension CoreDataManager {
    func getFirstDeck(with practiceType: PracticeType) -> CDDeck? {
        let practices = CoreDataManager.shared.getAll(ofType: CDPractice.self)
        
        for practice in practices {
            if practice.type == practiceType && practice.deck != nil {
                return practice.deck
            }
        }
        
        return nil
    }
}


