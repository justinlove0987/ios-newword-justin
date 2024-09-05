//
//  AppDelegate.swift
//  NewWord
//
//  Created by justin on 2024/3/29.
//

import UIKit
import FirebaseCore
import GoogleTranslateSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        initializeDataManager()
        FirebaseApp.configure()

        return true
    }

}

extension AppDelegate {

    func initializeDataManager() {
        _ = CoreDataManager.shared

        if UserDefaultsManager.shared.preferredFontSize == 0 {
            UserDefaultsManager.shared.preferredFontSize = 18
        }

        if UserDefaultsManager.shared.preferredLineSpacing == 0 {
            UserDefaultsManager.shared.preferredLineSpacing = 5
        }
        
        if !CoreDataManager.shared.deckExists() {
            CoreDataManager.shared.addDeck(name: "單字複習牌組")
            CoreDataManager.shared.addDeck(name: "句子複習牌組")
            
            let decks = CoreDataManager.shared.getDecks()
            
            var items: [CDSelectableItem] = []
            
            for deck in decks {
                guard let id = deck.id else { return }
                let item = CoreDataManager.shared.createSelectableItem(from: id)
                items.append(item)
            }
            
            CoreDataManager.shared.addSelectableItemList(items: items, type: .deck)
        }

        _ = PersistentContainerManager.shared
        
        createDefaultPracticeMap()
    }
    
    func createDefaultPracticeMap() {
//        PracticeManager.shared.deleteAllEntities()
        
        let practiceMaps = PracticeMapManager.shared.fetchAll()
        
        if practiceMaps.isEmpty {
            let type = Practice.PracticeType.listenAndTranslate.rawValue

            let preset = PracticePreset(defaultPreset: DefaultPracticePreset())
            
            let resource = PracticeServerProvidedContent()
            
            let practice = Practice(typeRawValue: type,
                                    preset: preset,
                                    serverProvidedContent: resource,
                                    userGeneratedContent: nil,
                                    records: [])

            let sequence = PracticeSequence(practices: [practice])

            let map = PracticeMap(type: 0, sequences: [sequence])

            PracticeMapManager.shared.create(model: map)

//            print("foo - \(map.sequences.first?.practices.first?.resource)")
//            print("foo - \(practiceMap.practiceMatrix.first?.first?.resource)")
//            print("foo - \(map?.practiceMatrix.first)")
//            print("foo - \(map?.practiceMatrix.first?.first)")
//            print("foo - \(map?.practiceMatrix.first?.first?.resource)")
            
            
        }
    }
}

