//
//  Deck.swift
//  NewWord
//
//  Created by justin on 2024/4/12.
//

import Foundation

// TODO: - 考慮要不要做subDeck
struct Deck: Hashable, Codable {

    struct NewCard: Codable {
        /// It's day
        var graduatingInterval: Int
        /// It's day
        var easyInterval: Int
        /// It's second
        var learningStpes: Double
    }
    
    struct Lapses: Codable {
        enum LeachAction: String, Codable {
            case tagOnly
            case suspendCard
            case moveToStrengthenArea
        }

        var relearningSteps: Double
        var leachThreshold: Int
        var minumumInterval: Int
        var leachAction: LeachAction = .moveToStrengthenArea

        private enum CodingKeys: String, CodingKey {
            case relearningSteps
            case leachThreshold
            case minumumInterval
            case leachAction
        }
    }
    
    
    struct Master: Codable {
        var graduatingInterval: Int // 如果card達到多少interval就變成proficient card
        var consecutiveCorrects: Int // 如果card達到多少次correct就變成proficient card
    }

    struct Advanced: Codable {
        var startingEase: Double // 2.5
        let easyBonus: Double
    }

    var newCard: NewCard
    var lapses: Lapses
    var advanced: Advanced
    var master: Master

    let id: String
        var name: String
    
    var storedCardIds: [String]
    
    var cards: [Card] {
        return CardManager.shared.snapshot.filter { card in
            storedCardIds.contains(card.id)
        }
    }


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
        let deck = Deck(newCard: newCard, lapses: lapses, advanced: advanced, master: master, id: UUID().uuidString, name: "英文句子", storedCardIds: [])

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
