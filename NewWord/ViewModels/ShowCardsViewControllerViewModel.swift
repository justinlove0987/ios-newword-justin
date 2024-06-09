//
//  ShowCardsViewControllerViewModel.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/5/29.
//

import UIKit

class ShowCardsViewControllerViewModel {
    // 有三個模式 learn relearn review success
    // 過濾 三個模式
    // 當回答後，決定card要去哪個模式的array中，或是success
    // 檢查第一個array還有沒有卡片，沒有就到下一個去。
    
    enum CardsOrder: Int {
        case new
        case relearn
        case review
        case notToday
    }
    
    var cardsOrder: [CardsOrder] = [.new, .review, .relearn]
    
    var newCards: [CDCard] = []
    var reviewCards: [CDCard] = []
    var relearnCards: [CDCard] = []
    var redoCards: [CDCard] = []
    
    var currentIndex: (collectionIndex: Int, cardIndex: Int) = (0,0)
    
    var currentCard: CDCard? {
        return getCurrentCard() ?? nil
    }
    
    var hasNextCardCollection: Bool {
        return currentIndex.collectionIndex + 1 < cardsOrder.count
    }
    
    var deck: CDDeck?
    
    func setupCards() {
        guard let deck else { return }
        
        let cards = CoreDataManager.shared.cards(from: deck)
        
        newCards = cards.filter { card in
            let learningRecords = CoreDataManager.shared.learningRecords(from: card)
            return learningRecords.isEmpty
        }
        
        reviewCards = cards.filter { card in
            guard let review = card.latestLearningRecord else { return false }
            return (review.dueDate! <= Date() &&
                    review.status == .correct &&
                    (review.state == .learn || review.state == .review))
        }
        
        relearnCards = cards.filter { card in
            guard let review = card.latestLearningRecord else { return false }
            return (review.dueDate! <= Date() &&
                    review.status == .incorrect &&
                    (review.state == .relearn || review.state == .learn))
        }
    }
    
    func nextCard() -> CDCard? {
        let cards = getCurrentCardCollection()
        let hasNextCard = currentIndex.cardIndex + 1 < cards.count
        
        if hasNextCard {
            currentIndex.cardIndex += 1
            return getCurrentCard()
        } else {
            if hasNextCardCollection {
                let nextCollectionIndex = currentIndex.collectionIndex + 1
                let hasCard = hasCard(at: nextCollectionIndex)
                
                if hasCard {
                    currentIndex.collectionIndex += 1
                    currentIndex.cardIndex = 0
                    return getCurrentCard()
                    
                } else {
                    return nil
                    
                }
            }
            
            return nil
        }
    }
    
    func hasNextCard() -> Bool {
        // 1. 檢查 現在的collection有沒有下一張卡片
        // 2. 現在的collection沒有卡片 -> 檢查有沒有下一個collection
        // 3. 有下一個collection -> 檢查裡面有沒有卡片
        // 4. 有卡便回傳true
        
        let cards = getCurrentCardCollection()
        let hasNextCard = currentIndex.cardIndex + 1 < cards.count
        
        if !hasNextCard {
            if hasNextCardCollection {
                let nextCollectionIndex = currentIndex.collectionIndex + 1
                let hasCard = hasCard(at: nextCollectionIndex)
                
                return hasCard
                
            } else {
                return false
            }
        }
        
        return true
    }
    
    func hasCard(at collectionIndex: Int) -> Bool {
        let hasCollection = collectionIndex < cardsOrder.count
        
        if hasCollection {
            let currentCardCollection = getCurrentCardCollection()
            
            return currentCardCollection.count > 0
        }
        
        return false
    }
    
    func getCurrentCard() -> CDCard? {
        let hasCollection = currentIndex.collectionIndex < cardsOrder.count
        
        if hasCollection {
            let currentCards = getCurrentCardCollection()
            let hasCardIndex = currentIndex.cardIndex < currentCards.count
            
            if hasCardIndex {
                let card = currentCards[currentIndex.cardIndex]
                return card
            }
        }
        
        return nil
    }
    
    func getCurrentCardCollection() -> [CDCard] {
        let order = cardsOrder[currentIndex.collectionIndex]
        
        let currentCards: [CDCard]
        
        switch order {
        case .relearn:
            currentCards = relearnCards
        case .new:
            currentCards = newCards
        case .review:
            currentCards = reviewCards
        case .notToday:
            currentCards = []
        }
        
        return currentCards
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


        updateCurrentCard(card)
        moveCardToNextCollection(isAnswerCorrect: isAnswerCorrect)
    }
    
    func updateCurrentCard(_ card: CDCard) {
        let order = cardsOrder[currentIndex.collectionIndex]
        
        switch order {
        case .review:
            reviewCards[currentIndex.cardIndex] = card
        case .relearn:
            relearnCards[currentIndex.cardIndex] = card
        case .new:
            newCards[currentIndex.cardIndex] = card
        case .notToday:
            break
        }
    }
        
    func moveCardToNextCollection(isAnswerCorrect: Bool) {
        
        let order = cardsOrder[currentIndex.collectionIndex]
        
        switch order {
        case .review:
            let result = reviewCards.remove(at: currentIndex.cardIndex)
            if isAnswerCorrect {
                redoCards.append(result)
            } else {
                relearnCards.append(result)
            }
            
        case .relearn:
            let result = relearnCards.remove(at: currentIndex.cardIndex)
            
            if isAnswerCorrect {
                redoCards.append(result)
            } else {
                relearnCards.append(result)
            }
            
        case .new:
            let result = newCards.remove(at: currentIndex.cardIndex)
            
            if isAnswerCorrect {
                redoCards.append(result)
            } else {
                relearnCards.append(result)
            }
            
        case .notToday:
            break
        }
    }
    
}
