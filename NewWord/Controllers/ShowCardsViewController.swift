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
    
    var deck: Deck
    
    var filteredCards: [Card] = []
    
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
        let newCards = deck.cards.filter { card in
            card.learningRecords.isEmpty
        }
        
        let reviewCards = deck.cards.filter { card in
            guard let review = card.latestReview else { return false }
            
            return review.dueDate <= Date() && review.state == .review
        }
        
        let relearnCards = deck.cards.filter { card in
            guard let review = card.latestReview else { return false }
            
            return review.dueDate <= Date() && review.state == .relearn
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
        
        
//        let deck = DeckManager.shared.snapshot.first { deck in
//            return deck.id == self.deck.id
//        }!
//        
//        deck.cards.filter { card in
//            return
//        }
        
    }
    
    @IBAction func incorrectAction(_ sender: UIButton) {
        
    }
}

extension ShowCardsViewController {
    func insertFakeCards() {
        filteredCards.insert(Card(id: "1", note: Note(id: "1", noteType: .prononciation), learningRecords: []), at: 0)
    }
}


