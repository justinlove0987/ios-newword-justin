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
    
    var deck: CDDeck

    var filteredCards: [CDCard] = []

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
    
    private var currentCard: CDCard {
        return filteredCards[currentCardIndex]
    }
    
    // MARK: - Lifecycles
    
    init?(coder: NSCoder, deck: CDDeck) {
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

        let cards = CoreDataManager.shared.cards(from: deck)

        let newCards = cards.filter { card in
            let learningRecord = CoreDataManager.shared.learningRecords(from: card)
            return learningRecord.isEmpty
        }
        
        let reviewCards = cards.filter { card in
            guard let review = card.latestReview else { return false }
            
            return review.dueDate! <= Date() && review.state == .review
        }
        
        let relearnCards = cards.filter { card in
            guard let review = card.latestReview else { return false }
            
            return review.dueDate! <= Date() && review.state == .relearn
        }
        
        filteredCards = newCards + reviewCards + relearnCards
    }
    
    private func updateSubview() {
        let rawValue = currentCard.note?.noteType?.rawValue

        let subview: any ShowCardsSubviewDelegate

        switch rawValue {
        case 0:
            let viewModel = SentenceClozeViewModel(card: currentCard)
            subview = SentenceClozeView(viewModel: viewModel, card: currentCard)
        case 1:
            subview = PronounciationView()
        default:
            break
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
        
        
        let deck = DeckManager.shared.snapshot.first { deck in
            return deck.id == self.deck.id
        }!
        
        let card = deck.cards.first { card in
            return card.id == filteredCards[currentCardIndex].id
        }
        
        DeckManager.shared.snapshot
        
    }
    
    @IBAction func incorrectAction(_ sender: UIButton) {
        
    }
}

extension ShowCardsViewController {
    func insertFakeCards() {
        filteredCards.insert(Card(id: "1", note: Note(id: "1", noteType: .prononciation), learningRecords: []), at: 0)
    }
}


