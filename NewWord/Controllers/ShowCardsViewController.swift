//
//  ShowCardsViewController.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/5/16.
//

import UIKit

protocol ShowCardsSubviewDelegate: UIView {
    associatedtype CardStateType: RawRepresentable & CaseIterable where CardStateType.RawValue == Int

    var currentState: CardStateType { get set }
    
    func hasNextState() -> Bool
    
    func nextState()
}

extension ShowCardsSubviewDelegate {

    func hasNextState() -> Bool {
        let rawValue = currentState.rawValue
        let nextState = CardStateType(rawValue: rawValue+1)
        
        guard nextState != nil else { return false }
        
        return true
    }
    
    func nextState() {
        let rawValue = currentState.rawValue
        let nextState = CardStateType(rawValue: rawValue+1)
        
        guard let nextState else { return }
        
        currentState = nextState
    }
}

class ShowCardsViewController: UIViewController {

    enum AnswerState {
        case question
        case answer
    }

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var newLabel: UILabel!
    @IBOutlet weak var relearnLabel: UILabel!
    @IBOutlet weak var reviewLabel: UILabel!

    var deck: Deck
    
    var currentAnswerState: AnswerState = .question
    
    private var viewModel = ShowCardsViewControllerViewModel()

    private var lastShowingSubview: any ShowCardsSubviewDelegate = NoCardView() {
        willSet {
            lastShowingSubview.removeFromSuperview()
        }

        didSet {
            self.view.addSubview(lastShowingSubview)
            lastShowingSubview.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                lastShowingSubview.topAnchor.constraint(equalTo: contentView.topAnchor),
                lastShowingSubview.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                lastShowingSubview.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                lastShowingSubview.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            ])
        }
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
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    private func setup() {
        viewModel.deck = deck
        viewModel.setupCards()
        lastShowingSubview = viewModel.getCurrentSubview()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tap))
        view.addGestureRecognizer(tap)
    }

    @objc func tap(_ sender: UITapGestureRecognizer) {
        let hasNextState = lastShowingSubview.hasNextState()
        
        if hasNextState {
            lastShowingSubview.nextState()
            
        } else {
            let isAnswerCorrect = isTouchOnRightSide(of: contentView, at: sender.location(in: self.view))
            viewModel.addLearningRecordToCurrentCard(isAnswerCorrect: isAnswerCorrect)

            guard let _ = viewModel.nextCard() else {
                lastShowingSubview = NoCardView()
                return
            }
            
            lastShowingSubview = viewModel.getCurrentSubview()
        }
    }

    @IBAction func correctAction(_ sender: UIButton) {
        viewModel.addLearningRecordToCurrentCard(isAnswerCorrect: true)
        
        lastShowingSubview = viewModel.getCurrentSubview()
    }

    @IBAction func incorrectAction(_ sender: UIButton) {
        viewModel.addLearningRecordToCurrentCard(isAnswerCorrect: false)
        
        lastShowingSubview = viewModel.getCurrentSubview()
    }
    
    func isTouchOnRightSide(of view: UIView, at point: CGPoint) -> Bool {
        let midX = view.bounds.midX
        return point.x > midX
    }
}




