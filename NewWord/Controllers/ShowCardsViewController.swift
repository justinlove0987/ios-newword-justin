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

    private var currentCardIndex = 0 {
        didSet {
            nextCard()
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
        nextCard()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    private func setup() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tap))
        view.addGestureRecognizer(tap)
    }

    private func nextCard() {
        let noteType = currentCard.note.noteType

        let subview: UIView

        switch noteType {
        case .sentenceCloze(_):
            let viewModel = SentenceClozeViewModel(card: currentCard)
            subview = SentenceClozeView(viewModel: viewModel, card: currentCard)
        case .prononciation:
            subview = PronounciationView()
        }

        view.addSubview(subview)
        subview.frame = self.view.bounds
    }

    @objc func tap(_ sender: UITapGestureRecognizer) {
        currentCardIndex += 1
    }

}

extension ShowCardsViewController {
    func insertFakeData() {
        cards.insert(Card(id: "1", note: Note(id: "1", noteType: .prononciation), learningRecords: []), at: 0)
    }
}


