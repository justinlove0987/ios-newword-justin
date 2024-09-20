//
//  ShowCardsViewControllerViewModel.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/5/29.
//

import UIKit

class ShowCardsViewControllerViewModel {
    
    enum CardType: Int {
        case new
        case relearn
        case review
        case notToday
    }
    
    struct PracticePosition {
        let startPosition: (Int, Int)
        let endPosition: (Int,Int)
    }
    
    private var practiceRecordTypeOrder: [PracticeRecordStandardState] = [.learn, .review, .relearn]
    private var storageCards: [CDPractice] = []
    private var practicePositions: [PracticePosition] = []
    
    private var currentMatrix: (collectionIndex: Int, cardIndex: Int) = (0,0)
    
    private var practiceCollections: [[CDPractice]] = []
    
    private var currentPractice: CDPractice? {
        return getCurrentPractice() ?? nil
    }
    
    var hasNextCardCollection: Bool {
        return currentMatrix.collectionIndex + 1 < practiceRecordTypeOrder.count
    }
    
    var deck: CDDeck?

    var tapAction: ((UITapGestureRecognizer) -> ())?
    var answerStackViewShouldHidden: ((Bool) -> ())?

    // MARK: - Helpers

    func setupPractices() {
        guard let deck else { return }
        
        let newPractices = deck.newPractices
        let reviewPractices = deck.reviewPractices
        let relearnPractices = deck.relearnPractices
        
        for order in practiceRecordTypeOrder {
            switch order {
            case .learn:
                practiceCollections.append(newPractices)
            case .relearn:
                practiceCollections.append(relearnPractices)
            case .review:
                practiceCollections.append(reviewPractices)
            default:
                break
            }
        }
    }
    
    func getCardAfterMovingCard() -> CDPractice? {
        let cards = getCurrentCardCollection()
        let hasCards = currentMatrix.cardIndex < cards.count
        
        if hasCards {
            return getCurrentPractice()
        } else {
            return findPossibleCardInNextCollection()
        }
    }
    
    func findPossibleCardInNextCollection() -> CDPractice? {
        let hasCard = hasCard(at: currentMatrix.collectionIndex)
        
        if hasCard {
            return practiceCollections[currentMatrix.collectionIndex][currentMatrix.cardIndex]
        } else {
            if hasNextCardCollection {
                currentMatrix.collectionIndex += 1
                
                return findPossibleCardInNextCollection()
            }
        }
        
        return nil
    }
    
    func hasNoCard() -> Bool {
        var cardCount = 0
        
        for cardCollection in practiceCollections {
            for _ in cardCollection {
                cardCount += 1
            }
        }
        
        return cardCount > 0
    }
    
    func hasNextCard() -> Bool {
        let cards = getCurrentCardCollection()
        let hasNextCard = currentMatrix.cardIndex + 1 < cards.count
        
        if !hasNextCard {
            if hasNextCardCollection {
                let nextCollectionIndex = currentMatrix.collectionIndex + 1
                let hasCard = hasCard(at: nextCollectionIndex)
                
                return hasCard
                
            } else {
                return false
            }
        }
        
        return true
    }
    
    func hasCard(at collectionIndex: Int) -> Bool {
        let hasCollection = collectionIndex < practiceRecordTypeOrder.count
        
        if hasCollection {
            let currentCardCollection = getCurrentCardCollection()
            
            return currentCardCollection.count > 0
        }
        
        return false
    }
    
    func getCurrentPractice() -> CDPractice? {
        let hasCollection = currentMatrix.collectionIndex < practiceRecordTypeOrder.count
        
        if hasCollection {
            let currentCards = getCurrentCardCollection()
            let hasCardIndex = currentMatrix.cardIndex < currentCards.count
            
            if hasCardIndex {
                let card = currentCards[currentMatrix.cardIndex]
                return card
            } else {
                return findPossibleCardInNextCollection()
            }
        }
        
        return nil
    }
    
    func getCurrentCardCollection() -> [CDPractice] {
        let collection = practiceCollections[currentMatrix.collectionIndex]
        
        return collection
    }
    
    func getCurrentSubview() -> any ShowCardsSubviewDelegate {
        guard let practice = getCurrentPractice(),
              let type = practice.type else {
            return NoCardView()
        }
        
        let subview: any ShowCardsSubviewDelegate
        
        switch type {
        case .listenAndTranslate:
            guard let clozeView = ListeningClozeView(practice: practice) else {
                return NoCardView()
            }
            
            subview = clozeView
        
        default:
            subview = NoCardView()
        }
        
        return subview
    }
    
    func addLearningRecordToCurrentCard(isAnswerCorrect: Bool) {
        guard let practice = getCurrentPractice() else { return }
        guard let deck,
              let standardPreset = deck.presetc?.standardPreset else { return }

        practice.addRecord(userPressedStatusType: .easy,
                           standardPreset: standardPreset)
    }
    
    func moveCard(isAnswerCorrect: Bool) {
        guard practiceCollections[currentMatrix.collectionIndex].count > 0 else { return }
        
        let moveCard = practiceCollections[currentMatrix.collectionIndex].remove(at: currentMatrix.cardIndex)
        
        if isAnswerCorrect {
            storageCards.append(moveCard)
        } else {
            addCardToCollection(moveCard, type: .relearn)
        }
    }
    
    func addCardToCollection(_ card: CDPractice, type: PracticeRecordStandardState) {
        for (i, cardType) in practiceRecordTypeOrder.enumerated() {
            if type == cardType {
                practiceCollections[i].append(card)
            }
        }
    }
    
    func getCollectionCounts() -> (new: Int, relearn: Int, review: Int) {
        var new = 0
        var review = 0
        var relearn = 0

        for (i,order) in practiceRecordTypeOrder.enumerated() {
            switch order {
            case .learn:
                new = practiceCollections[i].count
            case .relearn:
                relearn = practiceCollections[i].count
            case .review:
                review = practiceCollections[i].count
            default:
                break
            }
        }

        return (new: new, relearn: relearn, review: review)
    }
    
}

extension ShowCardsViewControllerViewModel: ClozeViewProtocol {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let action = answerStackViewShouldHidden else { return false }
        
        textField.resignFirstResponder()
        action(false)
        
        return true
    }
    
    func tap(from view: ClozeView, _ sender: UITapGestureRecognizer) {
        if let textField = UIResponder.currentFirst() as? UITextField {
            textField.resignFirstResponder()
            return
        }
        
        guard let action = tapAction else { return }
        action(sender)
    }
}
