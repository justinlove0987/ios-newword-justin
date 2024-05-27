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
    
    var cards: [CDCard] = []
    var card: CDCard?

    var numberOfRowsInSection: Int = 0
    var wordsForRows: [[Word]] = []
    var data: Rows!
    
    weak var textField: WordTextField?
    
    init(card: CDCard) {
        self.card = card
    }
    
    init() {
//        self.card = Card(id: "", note: Note(id: "", noteType: .sentenceCloze(SentenceCloze(clozeWord: Word(text: "", chinese: ""), sentence: []))), learningRecords: [])
    }
    
    mutating func setup(with width: CGFloat) {
        self.width = width
        self.updateData(width: width)
    }
    
    func getCurrentCard() -> CDCard {
        return card!
    }
    
    func getCurrentClozeChinese() -> Word? {
        let noteType = card!.note!.noteType!.rawValue

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
}
