//
//  ShowCardsViewController.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/5/16.
//

import UIKit

protocol ShowCardsSubviewDelegate: UIView {
    associatedtype CardStateType: RawRepresentable where CardStateType.RawValue == Int

    var currentState: CardStateType { get set }

    func nextState()
    func hasNextState() -> Bool
}

class ShowCardsViewController: UIViewController {

    enum AnswerState {
        case answering
        case showingAnswer
    }

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var newLabel: UILabel!
    @IBOutlet weak var relearnLabel: UILabel!
    @IBOutlet weak var reviewLabel: UILabel!

    var deck: Deck

    private var newCards: [Card] = [] {
        didSet {
            newLabel.text = "\(newCards.count)"
        }
    }

    private var reviewCards: [Card] = [] {
        didSet {
            reviewLabel.text = "\(reviewCards.count)"
        }
    }


    private var relearnCards: [Card] = [] {
        didSet {
            relearnLabel.text = "\(relearnCards.count)"
        }
    }

    private var filteredCards: [Card] = []

    private var lastShowingSubview: any ShowCardsSubviewDelegate = NoCardView() {
        willSet {
            lastShowingSubview.removeFromSuperview()
        }

        didSet {
            contentView.addSubview(lastShowingSubview)
            lastShowingSubview.frame = contentView.bounds
        }
    }

    private var currentCardIndex = 0 {
        didSet {
            updateSubview()
        }
    }

    private var currentCard: Card {
        return filteredCards[currentCardIndex]
    }

    // MARK: - Lifecycles

    init?(coder: NSCoder, deck: Deck) {
        self.deck = deck
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupCards()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    private func setup() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tap))
        view.addGestureRecognizer(tap)
    }

    private func setupCards() {
        filterCards()
        insertFakeCards()

        let hasCards = filteredCards.count > 0

        if hasCards {
            updateSubview()
        } else {
            lastShowingSubview = NoCardView()
        }
    }

    private func filterCards() {
        newCards = deck.cards.filter { card in
            card.learningRecords.isEmpty
        }

        reviewCards = deck.cards.filter { card in
            guard let review = card.latestReview else { return false }
            return (review.dueDate <= Date() &&
                    review.status == .correct &&
                    (review.state == .learn || review.state == .review))
        }

        relearnCards = deck.cards.filter { card in
            guard let review = card.latestReview else { return false }
            return (review.dueDate <= Date() &&
                    review.status == .incorrect &&
                    (review.state == .relearn || review.state == .learn))
        }

        filteredCards = newCards + reviewCards + relearnCards
    }

    private func updateSubview() {
        let noteType = currentCard.note.noteType

        let subview: any ShowCardsSubviewDelegate

        switch noteType {
        case .sentenceCloze(_):
            let viewModel = SentenceClozeViewModel(card: currentCard)
            subview = SentenceClozeView(viewModel: viewModel, card: currentCard)
        case .prononciation:
            subview = PronounciationView()
        }

        lastShowingSubview = subview
    }

    @objc func tap(_ sender: UITapGestureRecognizer) {
        let hasNextState = lastShowingSubview.hasNextState()

        if hasNextState {
            lastShowingSubview.nextState()
        } else {

            let hasNextCard = currentCardIndex+1 < filteredCards.count

            if hasNextCard {
                currentCardIndex += 1
            } else {
                lastShowingSubview = NoCardView()
            }
        }
    }

    @IBAction func correctAction(_ sender: UIButton) {
        let record = LearningRecord.createLearningRecord(lastCard: currentCard, deck: deck, isAnswerCorrect: true)
        filteredCards[currentCardIndex].learningRecords.append(record)
        CardManager.shared.update(data: filteredCards[currentCardIndex])

        // 一方面要對正在用的資料進行操作 另一方面要對本地端的資料進行操作
        // 檢查是否要繼續放入filtered card，不要就從filteredcard中剔除
        // 先訂一個順序就好 new review relearn
        // 怎麼讓new學完後再學下一個review？

        if record.dueDate <= Date() {

        }
    }

    @IBAction func incorrectAction(_ sender: UIButton) {

    }
}

extension ShowCardsViewController {
    func insertFakeCards() {
        filteredCards.insert(Card(id: "1", note: Note(id: "1", noteType: .prononciation), learningRecords: []), at: 0)
    }
}

struct LearningFactory {
    // 有三個模式 learn relearn review success
    // 過濾 三個模式
    // 當回答後，決定card要去哪個模式的array中，或是success
    // 檢查第一個array還有沒有卡片，沒有就到下一個去。

    enum CardCategory: Int {
        case new
        case relearn
        case review
        case notToday
    }

    var cardsOrder: [CardCategory] = [.new, .review, .relearn]

    var newCards: [Card] = []
    var reviewCards: [Card] = []
    var relearnCards: [Card] = []
    var redoCards: [Card] = []

    var currentIndex: (collectionIndex: Int, cardIndex: Int) = (0,0)

    var deck: Deck

    init(deck: Deck) {
        self.deck = deck
    }

    mutating func setupCards() {
        newCards = deck.cards.filter { card in
            card.learningRecords.isEmpty
        }

        reviewCards = deck.cards.filter { card in
            guard let review = card.latestReview else { return false }
            return (review.dueDate <= Date() &&
                    review.status == .correct &&
                    (review.state == .learn || review.state == .review))
        }

        relearnCards = deck.cards.filter { card in
            guard let review = card.latestReview else { return false }
            return (review.dueDate <= Date() &&
                    review.status == .incorrect &&
                    (review.state == .relearn || review.state == .learn))
        }
    }

    func getCurrentCard() -> Card {
        let order = cardsOrder[currentIndex.collectionIndex]

        let currentCards: [Card]

        switch order {
        case .relearn:
            currentCards = relearnCards
        case .new:
            currentCards = newCards
        case .review:
            currentCards = reviewCards
        case .notToday:
            currentCards = []
        }

        let card = currentCards[currentIndex.cardIndex]

        return card
    }
}


