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
    
    var newCards: [Card] = []
    var reviewCards: [Card] = []
    var relearnCards: [Card] = []
    var redoCards: [Card] = []
    
    var currentIndex: (collectionIndex: Int, cardIndex: Int) = (0,0)
    
    var currentCard: Card? {
        return getCurrentCard() ?? nil
    }
    
    var hasNextCardCollection: Bool {
        return currentIndex.collectionIndex + 1 < cardsOrder.count
    }
    
    var deck: Deck?
    
    func setupCards() {
        guard let deck else { return }
        
        deck.cards.forEach { print("learning records count \($0.learningRecords.count)") }
        
        newCards = deck.cards.filter { card in
            card.learningRecords.isEmpty
        }
        
        reviewCards = deck.cards.filter { card in
            guard let review = card.latestReview else { return false }
            return (review.dueDate <= Date() &&
                    review.status == .correct &&
                    (review.state == .learn || review.state == .review))
        }
        
        relearnCards = deck.cards.filter { card in
            guard let review = card.latestReview else { return false }
            return (review.dueDate <= Date() &&
                    review.status == .incorrect &&
                    (review.state == .relearn || review.state == .learn))
        }
        
//        let card = Card(id: "1", note: Note(id: "1", noteType: .prononciation), learningRecords: [])
//        newCards.insert(card, at: 0)
    }
    
    func nextCard() -> Card? {
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
    
    func getCurrentCard() -> Card? {
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
    
    func getCurrentCardCollection() -> [Card] {
        let order = cardsOrder[currentIndex.collectionIndex]
        
        let currentCards: [Card]
        
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
        
        let noteType = card.note.noteType
        
        let subview: any ShowCardsSubviewDelegate
        
        switch noteType {
        case .sentenceCloze(_):
            let viewModel = SentenceClozeViewModel(card: card)
            subview = SentenceClozeView(viewModel: viewModel, card: card)
        case .prononciation:
            subview = PronounciationView()
        }
        
        return subview
    }
    
    func addLearningRecordToCurrentCard(isAnswerCorrect: Bool) {
        guard let deck = deck else { return }
        guard var card = getCurrentCard() else { return }
        
        let record = LearningRecord.createLearningRecord(lastCard: card, deck: deck, isAnswerCorrect: isAnswerCorrect)
        
        card.addLearningRecord(record)
        updateCurrentCard(card)
        moveCardToNextCollection(isAnswerCorrect: isAnswerCorrect)
        
        CardManager.shared.update(data: card)
    }
    
    func updateCurrentCard(_ card: Card) {
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
