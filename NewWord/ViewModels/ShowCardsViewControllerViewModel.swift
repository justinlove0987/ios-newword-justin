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
            
            if practice.isDue && practice.isActive {
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
    
    func addLearningRecord(to practice: CDPractice,
                                        userPressedStatusType: PracticeStandardStatusType) {
        guard let deck,
              let standardPreset = deck.preset?.standardPreset else { return }

        practice.addRecord(userPressedStatusType: userPressedStatusType,
                           standardPreset: standardPreset)
    }
    
    func deactivatePracticeIfThresholdReached(_ practice: CDPractice) {
        guard let deck,
              let standardPreset = deck.preset?.standardPreset else { return }
        
        let hasReachedThresholdCondition = standardPreset.hasReachedThresholdCondition(practice)
        
        practice.isActive = !hasReachedThresholdCondition
        
        for i in 0..<practiceCollections.count {
            let currentCollection = practiceCollections[i]
            
            for j in 0..<currentCollection.count {
                let currentPractice = currentCollection[j]
                
                if practice == currentPractice && hasReachedThresholdCondition {
                    practiceCollections[i].remove(at: j)
                    break
                }
            }
        }
    }
    
    func move(_ practice: CDPractice, userPressedStatusType: PracticeStandardStatusType) {
        guard let intervalType = practice.latestPracticeStandardRecord?.intervalType else {
            return
        }
        
        switch intervalType {
        case .new, .firstPractice, .forget:
            
            switch userPressedStatusType {
            case .again, .hard, .good:
                practiceCollections[2].append(practice)
            case .easy, .new:
                break
            }
            
        case .remember:
            switch userPressedStatusType {
            case .again:
                practiceCollections[2].append(practice)
            case .hard, .good, .easy, .new:
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
