//
//  ShowCardsViewController.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/5/16.
//

import UIKit

class ShowCardsViewController: UIViewController {
    
    @IBOutlet weak var stackView: UIStackView!
    
    var cards: [Card]
    
    private var currentIndex = 0
    
    private var currentCard: Card {
        return cards[currentIndex]
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
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //        var vc: UIViewController? // Declare vc variable
        //
        //        let type = currentCard.note.noteType
        //
        //        switch type {
        //        case .sentenceCloze(_):
        //            let storyboard = UIStoryboard(name: "Main", bundle: nil)
        //
        //            guard let sentenceClozeVC = storyboard.instantiateViewController(withIdentifier: String(describing: SentenceClozeViewController.self)) as? SentenceClozeViewController else {
        //                return
        //            }
        //
        //            sentenceClozeVC.card = currentCard
        //            vc = sentenceClozeVC
        //
        //            containerView = vc?.view
        
        //            let viewModel = SentenceClozeViewModel(card: currentCard)
        //            let view = SentenceClozeView(frame: .zero, viewModel: viewModel, card: currentCard)
        
        
        //        if let viewController = vc {
        //            viewController.modalPresentationStyle = .fullScreen
        //            viewController.modalTransitionStyle = .crossDissolve
        //            navigationController?.present(viewController, animated: false)
        //        }
        
        
        let viewModel = SentenceClozeViewModel(card: currentCard)
        let view = SentenceClozeView(frame: CGRect.zero, viewModel: viewModel, card: currentCard)
        stackView.addArrangedSubview(view)
    }
    
}


