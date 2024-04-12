//
//  SentenceClozeViewModel.swift
//  NewWord
//
//  Created by justin on 2024/4/1.
//

import UIKit


struct SentenceClozeViewModel {

    struct DataSource {
        let card: Card
        let note: Note
        let sentenceCloze: SentenceCloze
    }

    var index = 0

    let sentences: [Card] = Card.createFakeData()

    var numberOfRowsInSection: Int = 0

    var wordsForRows: [[Word]] = []

    var width: CGFloat!

    var hasNextSentence: Bool {
        let nextIndex = index + 1
        return nextIndex < sentences.count
    }

//    var datasource: DataSource

//    init() {
//        let dataSource = DataSource(card: <#T##Card#>, note: <#T##Note#>, sentenceCloze: <#T##SentenceCloze#>)
//    }

    mutating func setup(with width: CGFloat) {
        self.width = width
        configureWordsInRows(width: width)
    }

    func getCurrentSentence () -> Sentence {
        let cards = Card.createFakeData()
        let noteType = cards[index].note.noteType

        if case .sentenceCloze(let sentenceCloze) = noteType {
            let sentence = sentenceCloze.sentence
            return sentence
        }

        return Sentence(words: [])
    }

    mutating func nextSentence() {
        let nextIndex = index + 1
        index = nextIndex

        configureWordsInRows(width: width)
    }

    mutating func configureWordsInRows(width: CGFloat){
        let sentence = getCurrentSentence()
        var wordsInRows: [[Word]] = []
        var items: [Word] = []
        var currentBounds: CGFloat = 0

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

        self.wordsForRows = wordsInRows
        self.numberOfRowsInSection = wordsInRows.count
    }

    func createAlertController() -> UIAlertController {
        let alertController = UIAlertController(title: nil, message: "完成練習", preferredStyle: .alert)

        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)

        return alertController
    }

}
