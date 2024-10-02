//
//  SelectDeckViewController.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/10/1.
//

import UIKit

enum SelectDeckItemType: Hashable {
    case existingDeck(CDDeck)
    
    var title: String {
        switch self {
        case .existingDeck(let deck):
            guard let title = deck.name else {
                return "未命名"
            }
            
            return title
        }
    }
}

class SelectDeckViewController: ReusableCollectionViewController<SelectDeckItemType> {
    
    var blueprintPractice: CDPractice?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupItems()
        setupSelectedItem()
        setupProperties()
    }
    
    private func setupItems() {
        guard let blueprintPracticeType = blueprintPractice?.type else {
            return
        }
        
        let decks = CoreDataManager.shared.getAll(ofType: CDDeck.self)
        
        let sortedDecks = decks.sorted { lDeck, rDeck in
            if lDeck.practiceType == blueprintPracticeType || rDeck.practiceType == blueprintPracticeType {
                return lDeck.practiceType == blueprintPracticeType
            }
            
            
            guard let lName = lDeck.name,
                  let rName = rDeck.name else {
                return false
            }
            
            return lName < rName
        }
        
        var items: [SelectDeckItemType] = []
        
        for deck in sortedDecks {
            items.append(SelectDeckItemType.existingDeck(deck))
        }
        
        self.items = items
    }
    
    private func setupSelectedItem() {
        guard let blueprintPractice,
              let blurprintPracticeType = blueprintPractice.type else {
            return
        }
        
        if let blueprintDeck = blueprintPractice.deck {
            selectedItem = SelectDeckItemType.existingDeck(blueprintDeck)
            return
        }
        
        let decks = CoreDataManager.shared.getAll(ofType: CDDeck.self)
        
        for deck in decks {
            if deck.practiceType == blurprintPracticeType {
                selectedItem = SelectDeckItemType.existingDeck(deck)
                return
            }
        }
    }
    
    private func setupProperties() {
        self.title = "練習牌組"
        view.backgroundColor = .background
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        super.collectionView(collectionView, didSelectItemAt: indexPath)
        
        let selectedDeckType = items[indexPath.row]
        
        switch selectedDeckType {
            
        case .existingDeck(let deck):
            blueprintPractice?.deck = deck
        }
    }
    
    override func cellProvider(
        collectionView: UICollectionView,
        indexPath: IndexPath,
        itemIdentifier: Row
    ) -> UICollectionViewCell? {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RadioButtonCell.reuseIdentifier, for: indexPath) as! RadioButtonCell
        
        cell.configure(row: itemIdentifier)
        
        return cell
    }
}
