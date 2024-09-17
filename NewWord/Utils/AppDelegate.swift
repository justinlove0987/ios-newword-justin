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
        
        let maps = CoreDataManager.shared.getAll(ofType: CDPracticeMap.self)
        
        if maps.isEmpty {
            let practiceTypeRawValue = Practice.PracticeType.listenAndTranslate.rawValue
            
            let presetDefault = CoreDataManager.shared.createPracticePresetDefault()
            let preset = CoreDataManager.shared.createEntity(ofType: CDPracticePreset.self)
            let practice = CoreDataManager.shared.createEntity(ofType: CDPractice.self)
            let sequence = CoreDataManager.shared.createEntity(ofType: CDPracticeSequence.self)
            let map = CoreDataManager.shared.createEntity(ofType: CDPracticeMap.self)
            
            preset.practicePresetDefault = presetDefault
            
            practice.preset = preset
            practice.typeRawValue = practiceTypeRawValue.toInt64
            practice.sequence = sequence
            
            sequence.map = map
            
            CoreDataManager.shared.save()
        }
    }
}

