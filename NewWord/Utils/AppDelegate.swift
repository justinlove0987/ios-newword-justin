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
    
    func tryTranslation() {
        let service = GoogleTranslateApiService(apiKey: "AIzaSyAu4IIgc3WDKFuq8AGD6g1Rliz83qS5q0k")

        let english = Locale(identifier: "en")
        let swedish = Locale(identifier: "zh-TW")

        service.translate("Hello, world!", from: english, to: swedish) { result in
            switch result {
            case .success(let translatedText):
                print("foo - \(translatedText)")
//                let result = translatedText.translations.first!.translatedText

            case .failure(let error):
                print(error)
            }
        }
    }

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
    }
}

