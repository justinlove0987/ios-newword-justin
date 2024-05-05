//
//  Deck.swift
//  NewWord
//
//  Created by justin on 2024/4/12.
//

import Foundation


struct Deck: Hashable {

    enum Interval {
        case learnCorrect
        case learnIncorrect
        case reviewCorrect
        case reviewIncorrect
        case relearnCorrect
        case relearnIncorrect
    }

    struct NewCard {
        /// It's day
        let graduatingInterval: Int
        /// It's day
        let easyInterval: Int
        /// It's second
        let learningStpes: Double
    }
    
    struct Lapses {
        enum LeachAction {
            case tagOnly
            case suspendCard
            case moveToStrengthenArea
        }

        /// It's second
        let relearningSteps: Double
        
        /// The number of times Again needs to be pressed on a review card before it is marked as a leech. Leeches are cards that consume a lot of your time, and when a card is marked as a leech, it's a good idea to rewrite it, delete it, or think of a mnemonic to help you remember it.
        let leachThreshold: Int
        
        /// The minimum interval given to a review card after answering Again.
        let minumumInterval: Int
        
        /// Tag Only: Add a "leech" tag to the note, and display a pop-up. Suspend Card: In addition to tagging the note, hide the card until it is manually unsuspended.
        let leachAction: LeachAction = .moveToStrengthenArea
    }
    
    struct Master {
        let graduatingInterval: Int // 如果card達到多少interval就變成proficient card
        let consecutiveCorrects: Int // 如果card達到多少次correct就變成proficient card
    }

    struct Advanced {
        let startingEase: Double // 2.5
        let easyBonus: Double
    }

    let newCard: NewCard
    let lapses: Lapses
    let advanced: Advanced
    let master: Master
    
    let id: String
    var name: String
    let cards: [Card]

    static func == (lhs: Deck, rhs: Deck) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Deck {
    static func createFakeDeck() -> Deck {
        let newCard = Deck.NewCard(graduatingInterval: 1, easyInterval: 3, learningStpes: 1)
        let lapses = Deck.Lapses(relearningSteps: 1, leachThreshold: 2, minumumInterval: 1)
        let advanced = Deck.Advanced(startingEase: 2.5, easyBonus: 1.3)
        let master = Deck.Master(graduatingInterval: 730, consecutiveCorrects: 5)

        let deck = Deck(newCard: newCard, lapses: lapses, advanced: advanced, master: master, id: UUID().uuidString, name: "英文句子", cards: [])

        return deck
    }
}


extension Deck {
    func isLeachCard(card: Card, answerIsCorrect: Bool = false) -> Bool {
        let filteredRecords = card.learningRecords.filter { reocrd in
            return reocrd.state == .relearn && reocrd.status == .correct
        }

        return filteredRecords.count + 1 >= lapses.leachThreshold
    }

    func isMasterCard(card: Card, answerIsCorrect: Bool = true) -> Bool {
        let filteredRecords = card.learningRecords.filter { reocrd in
            return reocrd.status == .correct
        }

        return filteredRecords.count + 1 >= master.consecutiveCorrects
    }
}
