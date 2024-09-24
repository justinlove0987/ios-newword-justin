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
        createFirstTimePracticeMap()
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
    
    func createFirstTimePracticeMap() {
        
        let decks = CoreDataManager.shared.getAll(ofType: CDDeck.self)
        let maps = CoreDataManager.shared.getAll(ofType: CDPracticeMap.self)
        
        if maps.isEmpty {
            let practiceTypeRawValue = PracticeType.listenAndTranslate.rawValue
            let practice = CoreDataManager.shared.createEntity(ofType: CDPractice.self)
            let sequence = CoreDataManager.shared.createEntity(ofType: CDPracticeSequence.self)
            let map = CoreDataManager.shared.createEntity(ofType: CDPracticeMap.self)
            
            for deck in decks {
                let preset = CoreDataManager.shared.createEntity(ofType: CDPracticePreset.self)
                let standardPreset = CoreDataManager.shared.createEntity(ofType: CDPracticePresetStandard.self)
                
                
                standardPreset.firstPracticeEase = 2.5
                
                preset.standardPreset = standardPreset
                
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
                
                deck.presetc = preset
            }
            
            practice.typeRawValue = practiceTypeRawValue.toInt64
            practice.sequence = sequence

            sequence.map = map
            
            CoreDataManager.shared.save()
        }
    }
}


enum PracticeType: Int, CaseIterable {
    case listenAndTranslate
    case listenReadChineseAndTypeEnglish
    case listenAndTypeEnglish
    case readAndTranslate

    var title: String {
        switch self {
        case .listenAndTranslate:
            return "聆聽並翻譯"
        case .listenReadChineseAndTypeEnglish:
            return "聆聽、閱讀中文並輸入英文"
        case .listenAndTypeEnglish:
            return "聆聽並輸入英文"
        case .readAndTranslate:
            return "閱讀並翻譯"
        }
    }
}
