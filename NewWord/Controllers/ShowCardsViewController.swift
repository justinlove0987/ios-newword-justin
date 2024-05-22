//
//  ShowCardsViewController.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/5/16.
//

import UIKit

class ShowCardsViewController: UIViewController {

    enum AnswerState {
        case answering
        case showingAnswer
    }

    var cards: [Card]

    private var lastShowingSubview: UIView = UIView() {
        willSet {
            lastShowingSubview.removeFromSuperview()
        }

        didSet {
            view.addSubview(lastShowingSubview)
            lastShowingSubview.frame = view.bounds
            print(view.subviews)
        }
    }

    private var currentCardIndex = 0 {
        didSet {
            updateCard()
        }
    }

    //    private var currentState: AnswerState = .answering {
    //        didSet {
    //            updateUI(state: currentState)
    //        }
    //    }

    private var currentCard: Card {
        return cards[currentCardIndex]
    }

    // MARK: - Lifecycles

    init?(coder: NSCoder, cards: [Card]) {
        self.cards = cards
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        insertFakeData()
        updateCard()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    private func setup() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tap))
        view.addGestureRecognizer(tap)
        
        let hasCards = cards.count > 0

        if hasCards {
            updateCard()
        } else {
            lastShowingSubview = NoCardView()
        }
    }

    private func updateCard() {
        let noteType = currentCard.note.noteType

        let subview: UIView

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
        let hasNextCard = currentCardIndex+1 < cards.count

        if hasNextCard {
            currentCardIndex += 1
        } else {
            lastShowingSubview = NoCardView()
        }

    }

}

extension ShowCardsViewController {
    func insertFakeData() {
        cards.insert(Card(id: "1", note: Note(id: "1", noteType: .prononciation), learningRecords: []), at: 0)
    }
}


