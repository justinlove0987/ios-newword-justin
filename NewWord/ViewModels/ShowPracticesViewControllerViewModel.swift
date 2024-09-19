//
//  ShowPracticesViewModel.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/9/17.
//

import Foundation


class ShowPracticesViewControllerViewModel {
    
    var deck: CDDeck?
    
    private var practiceCollections: [[CDPractice]] = []
    
    private var practiceRecordTypeOrder: [PracticeRecordStandardState] = [.learn, .review, .relearn]
    
    func setupPractices() {
//        guard let deck else { return }
//        
//        let practices = deck.practices
//        
//        let newPractices = deck.newPractices
//        let reviewPractices = deck.reviewPractices
//        let relearnPractices = deck.relearnPractices
////        
//        for order in practiceRecordTypeOrder {
//            switch order {
//            case .learn:
//                cardCollections.append(newPractices)
//            case .relearn:
//                cardCollections.append(reviewPractices)
//            case .review:
//                cardCollections.append(relearnPractices)
//            case .notToday:
//                break
//            }
//        }

    }
    
    
}
