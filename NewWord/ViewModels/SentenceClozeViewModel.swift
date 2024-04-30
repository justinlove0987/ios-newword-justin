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
//    let relearnCards: [Card]
//    let reviewCards: [Card]
//    let newCards: [Card]
//    let sortedCards: [Card]

    var numberOfRowsInSection: Int = 0
    var wordsForRows: [[Word]] = []
    var data: Rows!

    var hasNextCard: Bool {
        let nextIndex = index + 1
        return nextIndex < cards.count
    }
    
    weak var textField: WordTextField?

    init() {
//        self.relearnCards = cards.filter { $0.cardState == .relearn }
//        self.reviewCards = cards.filter { $0.cardState == .review }
//        self.newCards = cards.filter { $0.cardState == .new }

//        sortedCards = relearnCards + reviewCards + newCards
    }

    mutating func setup(with width: CGFloat) {
        self.width = width
        self.updateData(width: width)
    }

    func getCurrentCard() -> Card {
        return cards[index]
    }

    mutating func nextCard() {
        let nextIndex = index + 1
        index = nextIndex
    }
    
    func getCurrentClozeChinese() -> Word? {
        let card = cards[index]
        let noteType = card.note.noteType
        
        if case .sentenceCloze(let sentenceCloze) = noteType {
            return sentenceCloze.clozeWord
        }
        
        return nil
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
                let isClozeWord = word.text == clozeWord.text

                let greaterWidth: CGFloat = (isClozeWord && clozeWord.chineseSize.width > word.size.width) ? clozeWord.chineseSize.width : word.size.width
                
                if word.text == clozeWord.text && clozeWord.chinese == "像是我們" {
                    print(word.size.width)
                    print(clozeWord.chineseSize.width)


                }


                if (currentBounds + greaterWidth) >= width {
                    wordsInRows.append(items)
                    currentBounds = 0
                    items = []
                }

                currentBounds += greaterWidth
                currentBounds += Preference.spacing

                items.append(sentence.words[i])
            }

            wordsInRows.append(items)
            
            data = Rows(clozeWord: clozeWord, wordsForRows: wordsInRows)
        }
    }
    
    func showAnswer() {
        if let textField = textField {
            textField.text = textField.word.text
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
    
    func createLearningRecord(isAnswerCorrect: Bool) -> LearningRecord {
        let card = getCurrentCard()
        let deck = Deck.createFakeDeck()
        
        return LearningRecord.createLearningRecord(lastCard: card, deck: deck, isAnswerCorrect: isAnswerCorrect)
    }


    private func addInterval(to date: Date, dayInterval: Int) -> Date? {
        let interval: Int = dayInterval

        var dateComponents = DateComponents()
        dateComponents.day = interval

        let calendar = Calendar.current
        let futureDate = calendar.date(byAdding: dateComponents, to: date)

        return futureDate
    }

    private func addInterval(to date: Date, secondInterval: Double) -> Date {
        return date.addingTimeInterval(secondInterval)
    }
}
