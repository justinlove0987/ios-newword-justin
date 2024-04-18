//
//  SentenceClozeViewModel.swift
//  NewWord
//
//  Created by justin on 2024/4/1.
//

import UIKit


struct SentenceClozeViewModel {
    
    struct Rows {
        struct Row {
            var words: [Word]
        }
        
        var clozeWord: Word
        var rows: [Row] = []
        var wordsForRows: [[Word]]
        var numberOfRowsInSection: Int {
            return wordsForRows.count
        }
    }
    
    var width: CGFloat!

    var index = 0 {
        didSet {
            updateData(width: width)
        }
    }

    let cards: [Card] = Card.createFakeData()

    var numberOfRowsInSection: Int = 0

    var wordsForRows: [[Word]] = []
    
    var data: Rows!

    var hasNextSentence: Bool {
        let nextIndex = index + 1
        return nextIndex < cards.count
    }
    
    weak var textField: WordTextField?

    mutating func setup(with width: CGFloat) {
        self.width = width
        self.updateData(width: width)
    }

    func getCurrentCard() -> Card {
        return cards[index]
    }

    mutating func nextSentence() {
        let nextIndex = index + 1
        index = nextIndex
    }
    
    mutating func updateData(width: CGFloat) {
        let card = getCurrentCard()
        let noteType = card.note.noteType
        var wordsInRows: [[Word]] = []
        var items: [Word] = []
        var currentBounds: CGFloat = 0
        
        if case .sentenceCloze(let sentenceCloze) = noteType {
            let sentence = sentenceCloze.sentence
            let clozeWord = sentenceCloze.clozeWord
            
            for i in 0..<sentence.words.count {
                let word = sentence.words[i]

                if (currentBounds + word.bound.width) >= width {
                    wordsInRows.append(items)
                    currentBounds = 0
                    items = []
                }

                currentBounds += word.bound.width
                currentBounds += 10
                items.append(sentence.words[i])
            }

            wordsInRows.append(items)
            
            data = Rows(clozeWord: clozeWord, wordsForRows: wordsInRows)
        }
    }
    
    func showAnswer() {
        if let textField = textField {
            textField.text = textField.word
            textField.textColor = .red
            textField.isUserInteractionEnabled = false
        }
    }

    func createAlertController() -> UIAlertController {
        let alertController = UIAlertController(title: nil, message: "完成練習", preferredStyle: .alert)

        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)

        return alertController
    }
    
    func updateCardInformation() {
        let card = getCurrentCard()
//        let cardState = card.cardState
        let deck = Deck.createFakeDeck()


        if !card.hasReivews { // 當是new card時，basic是一天，然後透過starting ease去計算下一次的due date

            deck.newCard.easyInterval

            // LearningRecord(createdDate: Date(), dueDate: <#T##Date#>, interval: <#T##Double#>, status: .correct)
        }

//        switch cardState {
//        case .new:
//            <#code#>
//        case .review:
//            <#code#>
//        }
    }
}
