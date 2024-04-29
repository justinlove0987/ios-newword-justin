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
    
    func addLearningRecord(isAswerCorrect: Bool) -> LearningRecord {
        let card = getCurrentCard()
        let deck = Deck.createFakeDeck()
        let today: Date = Date()

        let currentLearningStatus: LearningRecord.Status = isAswerCorrect ? .correct : .incorrect


        // 第一次回答
        // TODO: - 調整 latestReview ease
        guard let latestReview = card.latestReview else {
            // When we don't have latest reivew, then it's a new card.
            let newCard = deck.newCard

            let dueDate: Date = isAswerCorrect ? addInterval(to: today, dayInterval: newCard.easyInterval)! : addInterval(to: today, secondInterval: newCard.learningStpes)

            return LearningRecord(learnedDate: today, dueDate: dueDate, status: currentLearningStatus, state: .learn)
        }


        if isAswerCorrect {
            if deck.isMasterCard(card: card) {
                let newInterval = latestReview.interval * (latestReview.ease + 0.2)
                let dueDate = today.addingTimeInterval(newInterval)
                return LearningRecord(learnedDate: today, dueDate: dueDate, status: .correct, state: .master)
            } else {
                
            }

        } else {
            if deck.isLeachCard(card: card) {
                return LearningRecord(learnedDate: today, dueDate: today, status: .incorrect, state: .leach)
            }
        }



        let lastStatus =  latestReview.status
        let lastState = latestReview.state

        let lastRecord = (lastState, lastStatus)

        switch (lastState, lastStatus) {
        // 複習
        case (.learn, .correct):
            if isAswerCorrect {
                // TODO: - 將答對時ease需要加上的趴數獨立出來
                let newInterval = latestReview.interval * (latestReview.ease + 0.2)
                let dueDate = today.addingTimeInterval(newInterval)
                return LearningRecord(learnedDate: today, dueDate: dueDate, status: currentLearningStatus, state: .review)
            } else {
                let relearningStpes = deck.lapses.relearningSteps
                let dueDate = addInterval(to: today, secondInterval: relearningStpes)

                return LearningRecord(learnedDate: today, dueDate: dueDate, status: currentLearningStatus, state: .relearn)
            }

        case (.learn, .incorrect):
            if isAswerCorrect {
                let interval = deck.newCard.graduatingInterval
                let dueDate = addInterval(to: today, dayInterval: interval)!
                return LearningRecord(learnedDate: today, dueDate: dueDate, status: .correct, state: .learn)
            } else {
                let interval = deck.lapses.relearningSteps
                let dueDate = addInterval(to: today, secondInterval: interval)

                return LearningRecord(learnedDate: today, dueDate: dueDate, status: currentLearningStatus, state: .learn)
            }

        case (.review, .correct):
            if isAswerCorrect {
                let newInterval = latestReview.interval * (latestReview.ease + 0.2)
                let dueDate = addInterval(to: today, secondInterval: newInterval)
                return LearningRecord(learnedDate: today, dueDate: dueDate, status: currentLearningStatus, state: .review)
            } else {
                let interval = deck.lapses.relearningSteps
                let dueDate = addInterval(to: today, secondInterval: interval)
                return LearningRecord(learnedDate: today, dueDate: dueDate, status: currentLearningStatus, state: .relearn)
            }


        case (.review, .incorrect):
            // 上一次回答review時候答錯，而且是第一次reivew
            // TODO: - 將答錯時，ease需要加上的趴數獨立出來

            if isAswerCorrect {
                let newInterval = 1
                let dueDate = addInterval(to: today, dayInterval: newInterval)!
                return LearningRecord(learnedDate: today, dueDate: dueDate, status: currentLearningStatus, state: .relearn)
            } else {
                let interval = deck.lapses.relearningSteps
                let dueDate = addInterval(to: today, secondInterval: interval)
                return LearningRecord(learnedDate: today, dueDate: dueDate, status: currentLearningStatus, state: .relearn)
            }
        case (.relearn, .correct):
            if isAswerCorrect {
                let newInterval = latestReview.interval * (latestReview.ease + 0.2)
                let dueDate = addInterval(to: today, secondInterval: newInterval)
                return LearningRecord(learnedDate: today, dueDate: dueDate, status: currentLearningStatus, state: .review)
            } else {
                let interval = deck.lapses.relearningSteps
                let dueDate = addInterval(to: today, secondInterval: interval)
                return LearningRecord(learnedDate: today, dueDate: dueDate, status: currentLearningStatus, state: .relearn)
            }

        case (.relearn, .incorrect):
            if isAswerCorrect {
                let newInterval = 1
                let dueDate = addInterval(to: today, dayInterval: newInterval)!
                return LearningRecord(learnedDate: today, dueDate: dueDate, status: currentLearningStatus, state: .relearn)
            } else {
                let interval = deck.lapses.relearningSteps
                let dueDate = addInterval(to: today, secondInterval: interval)
                return LearningRecord(learnedDate: today, dueDate: dueDate, status: currentLearningStatus, state: .relearn)
            }
        case (.leach, .incorrect):
            break
        case (.master, .correct):
            break
        default:
            fatalError()
            break
        }

        return LearningRecord(learnedDate: today, dueDate: today, status: .correct, state: .learn)
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
