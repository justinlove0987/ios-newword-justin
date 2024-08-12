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
            var words: [CDWord]
        }
        
        var clozeWord: CDWord
        var rows: [Row] = []
        var wordsForRows: [[CDWord]]
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
    
    var card: CDCard
    
    var numberOfRowsInSection: Int = 0
    var wordsForRows: [[CDWord]] = []
    var data: Rows!
    
    weak var textField: WordTextField?
    
    init(card: CDCard) {
        self.card = card
    }
    
    init() {
        self.card = CoreDataManager.shared.createEmptyCard()
    }
    
    mutating func setup(with width: CGFloat) {
        self.width = width
        self.updateData(width: width)
    }
    
    func getCurrentCard() -> CDCard {
        return card
    }
    
    func getCurrentClozeChinese() -> CDWord? {
        let resource = card.note!.wrappedResource
        
        if case .sentenceCloze(let sentenceCloze) = resource {
            return sentenceCloze.clozeWord!
        }
        
        return nil
    }
    
    mutating func updateData(width: CGFloat) {
        let card = getCurrentCard()
        let resource = card.note!.wrappedResource
        var wordsInRows: [[CDWord]] = []
        var items: [CDWord] = []
        var currentBounds: CGFloat = 0
        
        if case .sentenceCloze(let sentenceCloze) = resource {
            
            if let sentence = sentenceCloze.sentence,
               let clozeWord = sentenceCloze.clozeWord{
                
                let words = CoreDataManager.shared.words(from: sentence)
                
                for i in 0..<words.count {
                    let word = words[i]
                    let isClozeWord = word.text! == clozeWord.text!
                    
                    let greaterWidth: CGFloat = (isClozeWord && clozeWord.chineseSize.width > word.size.width) ? clozeWord.chineseSize.width : word.size.width
                    
                    
                    if (currentBounds + greaterWidth) >= width {
                        wordsInRows.append(items)
                        currentBounds = 0
                        items = []
                    }
                    
                    currentBounds += greaterWidth
                    currentBounds += Preference.spacing
                    
                    items.append(words[i])
                }
                
                wordsInRows.append(items)
                
                data = Rows(clozeWord: clozeWord, wordsForRows: wordsInRows)
            }
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
}
