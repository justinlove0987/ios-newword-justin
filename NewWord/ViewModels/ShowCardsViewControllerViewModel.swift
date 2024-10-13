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
    
    enum CardType: Int {
        case new
        case relearn
        case review
        case notToday
    }
    
    private var currentPractice: CDPractice? {
        return getCurrentPractice() ?? nil
    }
    
    var deck: CDDeck?

    var tapAction: ((UITapGestureRecognizer) -> ())?
    var answerStackViewShouldHidden: ((Bool) -> ())?

    weak var delegate: ShowCardsViewControllerViewModelDelegate?

    // MARK: - Helpers

    func getNewPracticeNumber() -> Int {
        guard let newPractices = deck?.newPractices else { return 0 }
        return newPractices.count
    }

    func getRelearnPracticeNumber() -> Int {
        guard let newPractices = deck?.relearnPractices else { return 0 }
        return newPractices.count
    }

    func getReviewPracticeNumber() -> Int {
        guard let newPractices = deck?.reviewPractices else { return 0 }
        return newPractices.count
    }

    func hasPractice() -> Bool {
        let count = getNewPracticeNumber() + getRelearnPracticeNumber() + getReviewPracticeNumber()

        return count > 0
    }
    
    func getCurrentPractice() -> CDPractice? {
        guard let deck else { return nil }

        let relearnPractices = deck.relearnPractices

        if !relearnPractices.isEmpty {
            return relearnPractices.first
        }

        let newPractices = deck.newPractices

        if !newPractices.isEmpty {
            return newPractices.first
        }

        let reviewPractices = deck.reviewPractices

        if !reviewPractices.isEmpty {
            return reviewPractices.first
        }
        
        return nil
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
