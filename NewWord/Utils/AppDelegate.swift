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
        
        CoreDataManager.shared.deleteAllEntities()
        
        createDecks()
        
        if !CoreDataManager.shared.hasPracticeMap() {
            CoreDataManager.shared.createPracticeMapBlueprint()
        }
    }
    
    func createDecks() {
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
    }
    
    private func createDeck() {
        for practiceType in PracticeType.allCases {
            let deck = CoreDataManager.shared.createEntity(ofType: CDDeck.self)
            let preset = CoreDataManager.shared.createEntity(ofType: CDPracticePreset.self)
            let standardPreset = createStandardPreset(practiceType: practiceType)
            
            preset.standardPreset = standardPreset
            
            assignStatusesToPreset(standardPreset)
            
            deck.id = UUID().uuidString
            deck.name = practiceType.title
            deck.presetc = preset
        }
    }

    private func createStandardPreset(practiceType: PracticeType) -> CDPracticePresetStandard {
        let standardPreset = CoreDataManager.shared.createEntity(ofType: CDPracticePresetStandard.self)
        standardPreset.firstPracticeEase = 2.5
        
        return standardPreset
    }

    private func assignStatusesToPreset(_ standardPreset: CDPracticePresetStandard) {
        for standardStatusType in PracticeStandardStatusType.allCases {
            let status = CoreDataManager.shared.createEntity(ofType: CDPracticeStatus.self)
            status.easeAdjustment = standardStatusType.easeAdjustment
            status.easeBonus = standardStatusType.easeBonus
            status.firstPracticeInterval = standardStatusType.firstPracticeInterval
            status.forgetInterval = standardStatusType.forgetInterval
            status.order = standardStatusType.order.toInt64
            status.title = standardStatusType.title
            status.typeRawValue = standardStatusType.rawValue.toInt64
            status.standardPreset = standardPreset
        }
    }
}
