//
//  ShowCardsViewControllerViewModel.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/5/29.
//

import UIKit

// TODO: - 如果下一個card collection沒有的話要繼續找下下一個card collection

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
    
    func nextCard() -> CDCard? {
        let cards = getCurrentCardCollection()
        let hasNextCard = currentMatrix.cardIndex + 1 < cards.count
        
        if hasNextCard {
            currentMatrix.cardIndex += 1
            return getCurrentCard()
        } else {
            if hasNextCardCollection {
                let nextCollectionIndex = currentMatrix.collectionIndex + 1
                let hasCard = hasCard(at: nextCollectionIndex)
                
                if hasCard {
                    currentMatrix.collectionIndex += 1
                    currentMatrix.cardIndex = 0
                    return getCurrentCard()
                    
                } else {
                    return nil
                    
                }
            }
            
            return nil
        }
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
            }
        }
        
        return nil
    }
    
    func getCurrentCardCollection() -> [CDCard] {
        let collection = cardCollections[currentMatrix.collectionIndex]
        
        return collection
    }
    
    func getCurrentSubview() -> any ShowCardsSubviewDelegate {
        guard let card = getCurrentCard() else { return NoCardView() }
        
        let noteType = card.note!.noteType!
        
        let subview: any ShowCardsSubviewDelegate
        
        switch noteType.content {
        case .sentenceCloze(_):
            let viewModel = SentenceClozeViewModel(card: card)
            subview = SentenceClozeView(viewModel: viewModel, card: card)
        case .prononciation:
            subview = PronounciationView()
        case .cloze:
            let viewModel = ClozeViewViewModel(card: card)
            let clozeView = ClozeView(card: card, viewModel: viewModel)
            clozeView.delegate = self
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
    
    func moveCardToNextCollection(isAnswerCorrect: Bool) {
        let order = cardTypeOrder[currentMatrix.collectionIndex]
        let moveCard = cardCollections[order.rawValue].remove(at: currentMatrix.cardIndex)
        
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
    
}

extension ShowCardsViewControllerViewModel: ClozeViewProtocol {    
    func tap(from view: ClozeView, _ sender: UITapGestureRecognizer) {
        if let textField = UIResponder.currentFirst() as? UITextField {
            textField.resignFirstResponder()
            return
        }
        
        guard let tapAction = tapAction else { return }
        tapAction(sender)
    }
}
