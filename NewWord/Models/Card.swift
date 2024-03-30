//
//  Card.swift
//  NewWord
//
//  Created by justin on 2024/3/29.
//

import Foundation

enum CardType {
    case cloze(Cloze)
}

struct Card {
    let cardId: String = ""
    let cardtype: CardType
    let addedDate: Date = Date()
    let firstReviewDate: Date = Date()
    let lastestReviewDate: Date = Date()
    let dueDate: Date = Date()
    let reviews: Int = 0
    let lapses: Int = 0
    let averageTime: Int = 0
    let totalTime: Int = 0
}

enum CardGroupType {
    case articleCloze(ArticleCloze)
}

struct CardGroup {
    let cardGroupId: String = ""
    let carGroupType: CardGroupType
    let cards: [Card]
}

struct ArticleCloze {
    let article: String
}

struct Cloze {
    let text: Vacabulary
    let range: NSRange
}
