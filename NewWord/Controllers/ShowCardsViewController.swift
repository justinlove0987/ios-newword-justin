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

    func setupAfterSubviewInHierarchy()
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

    func setupAfterSubviewInHierarchy() {}
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

    var deck: CDDeck
    
    var currentAnswerState: AnswerState = .question
    
    private var viewModel = ShowCardsViewControllerViewModel()

    var tapAction: ((UITapGestureRecognizer) -> ())?

    private var lastShowingSubview: any ShowCardsSubviewDelegate = NoCardView() {
        willSet {

            if let oldClozeView = lastShowingSubview as? ClozeView {
                oldClozeView.customInputView.textField.resignFirstResponder()
            }

            lastShowingSubview.removeFromSuperview()

            self.view.addSubview(newValue)
            newValue.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                newValue.topAnchor.constraint(equalTo: self.contentView.topAnchor),
                newValue.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
                newValue.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
                newValue.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
            ])

            view.layoutIfNeeded()

            newValue.setupAfterSubviewInHierarchy()
        }

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
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    private func setup() {
        tapAction = { sender in
            self.tapHelper(sender)
        }

        viewModel.deck = deck
        viewModel.setupCards()
        viewModel.tapAction = tapAction
        lastShowingSubview = viewModel.getCurrentSubview()

        let tap = UITapGestureRecognizer(target: self, action: #selector(tap))
        lastShowingSubview.addGestureRecognizer(tap)
    }

    @objc func tap(_ sender: UITapGestureRecognizer) {
        tapHelper(sender)
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

    private func tapHelper(_ sender: UITapGestureRecognizer) {
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

}




