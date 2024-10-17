//
//  ShowCardsViewControllerViewModel.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/5/29.
//

import UIKit

protocol ShowCardsViewControllerViewModelDelegate: AnyObject {
    func didPressReturnInTextField(_ textField: UITextField)
}

class ShowCardsViewControllerViewModel {
    
    enum PracticeType: Int {
        case new
        case relearn
        case review
        case notToday
    }
    
    struct PracticePosition {
        let startPosition: (Int, Int)
        let endPosition: (Int,Int)
    }
    
    private var practiceTypeOrder: [PracticeType] = [.new, .review, .relearn]
    private var storagePractices: [CDPractice] = []
    private var practicePositions: [PracticePosition] = []
    
    private var currentMatrix: (collectionIndex: Int, practiceIndex: Int) = (0,0)
    
    private var practiceCollections: [[CDPractice]] = []
    
    var deck: CDDeck?

    var tapAction: ((UITapGestureRecognizer) -> ())?
    var answerStackViewShouldHidden: ((Bool) -> ())?

    weak var delegate: ShowCardsViewControllerViewModelDelegate?
    
    var hasPractice: Bool {
        guard getCurrentPractice() != nil else {
            return false
        }

        return true
    }
    
    var hasNextPracticeCollection: Bool {
        return currentMatrix.collectionIndex + 1 < practiceTypeOrder.count
    }
    
    var isCurrentPracticeIndexWithinBounds: Bool {
        guard currentMatrix.collectionIndex < practiceCollections.count else {
            return false
        }
        
        let practiceCollection = practiceCollections[currentMatrix.collectionIndex]
        let practiceIndex = currentMatrix.practiceIndex
        
        return practiceIndex >= 0 && practiceIndex < practiceCollection.count
    }
    
    // MARK: - Helpers
    
    func getPracticeNumber(type: PracticeType) -> Int {
        switch type {
        case .new:
            return practiceCollections[0].count
        case .relearn:
            let practices = practiceCollections[2]
            let filteredPractices = practices.filter { $0.isDue }
            return filteredPractices.count
        case .review:
            return practiceCollections[1].count
        case .notToday:
            return 0
        }
    }
    
    func updatePracticesIntoCollections() {
        guard let deck else { return }
        
        for order in practiceTypeOrder {
            switch order {
            case .new:
                practiceCollections.append(deck.newPractices)
            case .relearn:
                practiceCollections.append(deck.relearnPractices)
            case .review:
                practiceCollections.append(deck.reviewPractices)
            case .notToday:
                break
            }
        }
    }
    
    func getCurrentPractice() -> CDPractice? {
        currentMatrix.collectionIndex = 0
        currentMatrix.practiceIndex = 0
        
        return getCurrentPracticeHelper()
    }
    
    func getCurrentPracticeHelper() -> CDPractice? {
        if isCurrentPracticeIndexWithinBounds {
            let practice = practiceCollections[currentMatrix.collectionIndex][currentMatrix.practiceIndex]
            
            if practice.isDue {
                return practice
            }
            
            currentMatrix.practiceIndex += 1
            
            return getCurrentPracticeHelper()
            
        } else if hasNextPracticeCollection {
            currentMatrix.collectionIndex += 1
            
            return getCurrentPracticeHelper()
        }
        
        return nil
    }
    
    func getCurrentPracticeCollection() -> [CDPractice] {
        return practiceCollections[currentMatrix.collectionIndex]
    }
    
    func getCurrentSubview() -> any ShowCardsSubviewDelegate {
        guard let practice = getCurrentPractice(),
              let type = practice.type else {
            return NoCardView()
        }
        
        let subview: any ShowCardsSubviewDelegate
        
        switch type {
        case .listenAndTranslate:
            guard let view = ListeningClozeView(practice: practice) else {
                return NoCardView()
            }
            
            subview = view
            
        case .readClozeAndTypeEnglish:
            let view = PracticeClozeView()
            view.practice = practice
            view.delegate = self
            
            subview = view
            
        default:
            subview = NoCardView()
        }
        
        return subview
    }
    
    func addLearningRecordToCurrentCard(userPressedStatusType: PracticeStandardStatusType) {
        guard let practice = getCurrentPractice() else { return }
        guard let deck,
              let standardPreset = deck.preset?.standardPreset else { return }

        practice.addRecord(userPressedStatusType: userPressedStatusType,
                           standardPreset: standardPreset)
    }
    
    func moveCard(userPressedStatusType: PracticeStandardStatusType) {
        guard practiceCollections[currentMatrix.collectionIndex].count > 0 else { return }
        
        let moveCard = practiceCollections[currentMatrix.collectionIndex].remove(at: currentMatrix.practiceIndex)
        
        
        guard let intervalType = moveCard.latestPracticeStandardRecord?.intervalType else {
            return
        }
        
        switch intervalType {
        case .new, .firstPractice, .forget:
            
            switch userPressedStatusType {
            case .again, .hard, .good:
                practiceCollections[2].append(moveCard)
            case .easy:
                break
            }
            
        case .remember:
            switch userPressedStatusType {
            case .again:
                practiceCollections[2].append(moveCard)
            case .hard, .good, .easy:
                break
            }
        case .unknown:
            break
        }
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

extension ShowCardsViewControllerViewModel: PracticeClozeViewDelegate {
    func didPressReturnInTextField(_ textField: UITextField) {
        delegate?.didPressReturnInTextField(textField)
    }
}

//class ShowCardsViewControllerViewModel {
//
//    enum CardType: Int {
//        case new
//        case relearn
//        case review
//        case notToday
//    }
//
//    struct CardPosition {
//        let startPosition: (Int, Int)
//        let endPosition: (Int,Int)
//    }
//
//    private var cardTypeOrder: [CardType] = [.new, .review, .relearn]
//    private var storageCards: [CDCard] = []
//    private var cardPositions: [CardPosition] = []
//
//    private var currentMatrix: (collectionIndex: Int, cardIndex: Int) = (0,0)
//
//    private var cardCollections: [[CDCard]] = []
//
//    private var currentCard: CDCard? {
//        return getCurrentCard() ?? nil
//    }
//
//    var hasNextCardCollection: Bool {
//        return currentMatrix.collectionIndex + 1 < cardTypeOrder.count
//    }
//
//    var deck: CDDeck?
//
//    var tapAction: ((UITapGestureRecognizer) -> ())?
//    var answerStackViewShouldHidden: ((Bool) -> ())?
//
//    // MARK: - Helpers
//
//    func setupCards() {
//        guard let deck else { return }
//
//        let tnewCards = CoreDataManager.shared.getNewCards(from: deck)
//        let treviewCards = CoreDataManager.shared.getReviewCards(from: deck)
//        let trelearnCards = CoreDataManager.shared.getRelearnCards(from: deck)
//
//        for cardOrder in cardTypeOrder {
//            switch cardOrder {
//            case .new:
//                cardCollections.append(tnewCards)
//            case .relearn:
//                cardCollections.append(trelearnCards)
//            case .review:
//                cardCollections.append(treviewCards)
//            case .notToday:
//                break
//            }
//        }
//    }
//
//    func getCardAfterMovingCard() -> CDCard? {
//        let cards = getCurrentCardCollection()
//        let hasCards = currentMatrix.cardIndex < cards.count
//
//        if hasCards {
//            return getCurrentCard()
//        } else {
//            return findPossibleCardInNextCollection()
//        }
//    }
//
//    func findPossibleCardInNextCollection() -> CDCard? {
//        let hasCard = hasCard(at: currentMatrix.collectionIndex)
//
//        if hasCard {
//            return cardCollections[currentMatrix.collectionIndex][currentMatrix.cardIndex]
//        } else {
//            if hasNextCardCollection {
//                currentMatrix.collectionIndex += 1
//
//                return findPossibleCardInNextCollection()
//            }
//        }
//
//        return nil
//    }
//
//    func hasNoCard() -> Bool {
//        var cardCount = 0
//
//        for cardCollection in cardCollections {
//            for _ in cardCollection {
//                cardCount += 1
//            }
//        }
//
//        return cardCount > 0
//    }
//
//    func hasNextCard() -> Bool {
//        let cards = getCurrentCardCollection()
//        let hasNextCard = currentMatrix.cardIndex + 1 < cards.count
//
//        if !hasNextCard {
//            if hasNextCardCollection {
//                let nextCollectionIndex = currentMatrix.collectionIndex + 1
//                let hasCard = hasCard(at: nextCollectionIndex)
//
//                return hasCard
//
//            } else {
//                return false
//            }
//        }
//
//        return true
//    }
//
//    func hasCard(at collectionIndex: Int) -> Bool {
//        let hasCollection = collectionIndex < cardTypeOrder.count
//
//        if hasCollection {
//            let currentCardCollection = getCurrentCardCollection()
//
//            return currentCardCollection.count > 0
//        }
//
//        return false
//    }
//
//    func getCurrentCard() -> CDCard? {
//        let hasCollection = currentMatrix.collectionIndex < cardTypeOrder.count
//
//        if hasCollection {
//            let currentCards = getCurrentCardCollection()
//            let hasCardIndex = currentMatrix.cardIndex < currentCards.count
//
//            if hasCardIndex {
//                let card = currentCards[currentMatrix.cardIndex]
//                return card
//            } else {
//                return findPossibleCardInNextCollection()
//            }
//        }
//
//        return nil
//    }
//
//    func getCurrentCardCollection() -> [CDCard] {
//        let collection = cardCollections[currentMatrix.collectionIndex]
//
//        return collection
//    }
//
//    func getCurrentSubview() -> any ShowCardsSubviewDelegate {
//        guard let card = getCurrentCard(),
//              let noteType = card.note?.type else {
//            return NoCardView()
//        }
//
//        let subview: any ShowCardsSubviewDelegate
//
//        switch noteType {
//        case .sentenceCloze:
//            let viewModel = SentenceClozeViewModel(card: card)
//            subview = SentenceClozeView(viewModel: viewModel, card: card)
//
//        case .prononciation:
//            subview = PronounciationView()
//
//        case .cloze:
//            guard let clozeView = ClozeView(card: card) else { return NoCardView() }
//            clozeView.delegate = self
//            subview = clozeView
//
//        case .lienteningCloze:
//            guard let clozeView = ListeningClozeView(card: card) else { return NoCardView() }
//            subview = clozeView
//        }
//
//        return subview
//    }
//
//    func addLearningRecordToCurrentCard(isAnswerCorrect: Bool) {
//        guard let deck = deck else { return }
//        guard let card = getCurrentCard() else { return }
//
//        let learningRecord = CoreDataManager.shared.createLearningRecord(lastCard: card, deck: deck, isAnswerCorrect: isAnswerCorrect)
//
//        CoreDataManager.shared.addLearningReocrd(learningRecord, to: card)
//    }
//
//    func moveCard(isAnswerCorrect: Bool) {
//        guard cardCollections[currentMatrix.collectionIndex].count > 0 else { return }
//
//        let moveCard = cardCollections[currentMatrix.collectionIndex].remove(at: currentMatrix.cardIndex)
//
//        if isAnswerCorrect {
//            storageCards.append(moveCard)
//        } else {
//            addCardToCollection(moveCard, type: .relearn)
//        }
//    }
//
//    func addCardToCollection(_ card: CDCard, type: CardType) {
//        for (i, cardType) in cardTypeOrder.enumerated() {
//            if type == cardType {
//                cardCollections[i].append(card)
//            }
//        }
//    }
//
//    func getCollectionCounts() -> (new: Int, relearn: Int, review: Int) {
//        var new = 0
//        var review = 0
//        var relearn = 0
//
//        for (i,order) in cardTypeOrder.enumerated() {
//            switch order {
//            case .new:
//                new = cardCollections[i].count
//            case .relearn:
//                relearn = cardCollections[i].count
//            case .review:
//                review = cardCollections[i].count
//            case .notToday:
//                break
//            }
//        }
//
//        return (new: new, relearn: relearn, review: review)
//    }
//
//}
