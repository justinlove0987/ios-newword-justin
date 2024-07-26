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
    
    struct CardPosition {
        let startPosition: (Int, Int)
        let endPosition: (Int,Int)
    }
    
    private var cardTypeOrder: [CardType] = [.new, .review, .relearn]
    private var storageCards: [CDCard] = []
    private var cardPositions: [CardPosition] = []
    
    private var currentMatrix: (collectionIndex: Int, cardIndex: Int) = (0,0)
    
    private var cardCollections: [[CDCard]] = []
    
    private var currentCard: CDCard? {
        return getCurrentCard() ?? nil
    }
    
    var hasNextCardCollection: Bool {
        return currentMatrix.collectionIndex + 1 < cardTypeOrder.count
    }
    
    var deck: CDDeck?

    var tapAction: ((UITapGestureRecognizer) -> ())?
    var answerStackViewShouldHidden: ((Bool) -> ())?

    // MARK: - Helpers

    func setupCards() {
        guard let deck else { return }
        
        let tnewCards = CoreDataManager.shared.getNewCards(from: deck)
        let treviewCards = CoreDataManager.shared.getReviewCards(from: deck)
        let trelearnCards = CoreDataManager.shared.getRelearnCards(from: deck)
        
        for cardOrder in cardTypeOrder {
            switch cardOrder {
            case .new:
                cardCollections.append(tnewCards)
            case .relearn:
                cardCollections.append(trelearnCards)
            case .review:
                cardCollections.append(treviewCards)
            case .notToday:
                break
            }
        }
    }
    
    func getCardAfterMovingCard() -> CDCard? {
        let cards = getCurrentCardCollection()
        let hasCards = currentMatrix.cardIndex < cards.count
        
        if hasCards {
            return getCurrentCard()
        } else {
            return findPossibleCardInNextCollection()
        }
    }
    
    func findPossibleCardInNextCollection() -> CDCard? {
        let hasCard = hasCard(at: currentMatrix.collectionIndex)
        
        if hasCard {
            return cardCollections[currentMatrix.collectionIndex][currentMatrix.cardIndex]
        } else {
            if hasNextCardCollection {
                currentMatrix.collectionIndex += 1
                
                return findPossibleCardInNextCollection()
            }
        }
        
        return nil
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
        let hasCollection = collectionIndex < cardTypeOrder.count
        
        if hasCollection {
            let currentCardCollection = getCurrentCardCollection()
            
            return currentCardCollection.count > 0
        }
        
        return false
    }
    
    func getCurrentCard() -> CDCard? {
        let hasCollection = currentMatrix.collectionIndex < cardTypeOrder.count
        
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
    
    func getCurrentCardCollection() -> [CDCard] {
        let collection = cardCollections[currentMatrix.collectionIndex]
        
        return collection
    }
    
    func getCurrentSubview() -> any ShowCardsSubviewDelegate {
        guard let card = getCurrentCard(),
              let noteType = card.note?.noteType else {
            return NoCardView()
        }
        
        let subview: any ShowCardsSubviewDelegate
        
        switch noteType.type {
        case .sentenceCloze:
            let viewModel = SentenceClozeViewModel(card: card)
            subview = SentenceClozeView(viewModel: viewModel, card: card)

        case .prononciation:
            subview = PronounciationView()

        case .cloze:
            guard let clozeView = ClozeView(card: card) else { return NoCardView() }
            clozeView.delegate = self
            subview = clozeView
            
        case .lienteningCloze:
            guard let clozeView = ListeningClozeView(card: card) else { return NoCardView() }
            subview = clozeView

        default:
            subview = NoCardView()
        }
        
        return subview
    }
    
    func addLearningRecordToCurrentCard(isAnswerCorrect: Bool) {
        guard let deck = deck else { return }
        guard let card = getCurrentCard() else { return }

        let learningRecord = CoreDataManager.shared.createLearningRecord(lastCard: card, deck: deck, isAnswerCorrect: isAnswerCorrect)

        CoreDataManager.shared.addLearningReocrd(learningRecord, to: card)
    }
    
    func moveCard(isAnswerCorrect: Bool) {
        let moveCard = cardCollections[currentMatrix.collectionIndex].remove(at: currentMatrix.cardIndex)
        
        if isAnswerCorrect {
            storageCards.append(moveCard)
        } else {
            addCardToCollection(moveCard, type: .relearn)
        }
    }
    
    func addCardToCollection(_ card: CDCard, type: CardType) {
        for (i, cardType) in cardTypeOrder.enumerated() {
            if type == cardType {
                cardCollections[i].append(card)
            }
        }
    }
    
    func getCollectionCounts() -> (new: Int, relearn: Int, review: Int) {
        var new = 0
        var review = 0
        var relearn = 0

        for (i,order) in cardTypeOrder.enumerated() {
            switch order {
            case .new:
                new = cardCollections[i].count
            case .relearn:
                relearn = cardCollections[i].count
            case .review:
                review = cardCollections[i].count
            case .notToday:
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
