//
//  ShowCardsViewController.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/5/16.
//

import UIKit

// TODO: - 調整answer stackView出現的時機

protocol ShowCardsSubviewDelegate: UIView {
    associatedtype CardStateType: RawRepresentable & CaseIterable where CardStateType.RawValue == Int

    var currentState: CardStateType { get set }

    func hasNextState() -> Bool
    
    func nextState()

    func setupAfterSubviewInHierarchy()
    
    func isFinalState() -> Bool
}

extension ShowCardsSubviewDelegate {
    
    func isFinalState() -> Bool {
        return currentState.rawValue + 1 == CardStateType.allCases.count
    }

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
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var newLabel: UILabel!
    @IBOutlet weak var relearnLabel: UILabel!
    @IBOutlet weak var reviewLabel: UILabel!
    @IBOutlet weak var rateStackView: UIStackView!
    @IBOutlet weak var answerTypeStackView: UIStackView!
    
    var deck: CDDeck
    
    private var viewModel = ShowCardsViewControllerViewModel()

    private var lastShowingSubview: any ShowCardsSubviewDelegate = NoCardView() {
        willSet {
            layout(newSubview: newValue)
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupUserdefaults()
    }

    // MARK: - Helpers

    private func setup() {
        setupUserdefaults()
        setupViewModel()
        setupProperty()
    }
    
    private func setupViewModel() {
        viewModel.deck = deck
        viewModel.setupCards()
        
        viewModel.tapAction = { sender in
            self.tapHelper(sender)
        }
        
        viewModel.answerStackViewShouldHidden = { shouldHidden in
            self.answerTypeStackView.isHidden = shouldHidden
        }
        
        lastShowingSubview = viewModel.getCurrentSubview()
    }
    
    private func setupProperty() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tap))
        self.view.addGestureRecognizer(tap)

        let collectionCounts = viewModel.getCollectionCounts()
        updateLabels(collectionCounts: collectionCounts)
        
        answerTypeStackView.isHidden = true
    }

    private func setupUserdefaults() {
        UserDefaultsManager.shared.clozeMode = .read
    }

    private func layout(newSubview: any ShowCardsSubviewDelegate) {
        if let oldClozeView = lastShowingSubview as? ClozeView {
            oldClozeView.customInputView.textField.resignFirstResponder()
        }

        lastShowingSubview.removeFromSuperview()

        self.view.addSubview(newSubview)
        
        newSubview.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            newSubview.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            newSubview.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            newSubview.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            newSubview.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
        ])
        
        view.layoutIfNeeded()
        
        newSubview.setupAfterSubviewInHierarchy()
        
        updateAnswerStateView(isFinalState: newSubview.isFinalState())
    }

    @objc func tap(_ sender: UITapGestureRecognizer) {
        tapHelper(sender)
    }

    private func tapHelper(_ sender: UITapGestureRecognizer) {
        let hasNextState = lastShowingSubview.hasNextState()

        if hasNextState {
            lastShowingSubview.nextState()
            updateAnswerStateView(isFinalState: lastShowingSubview.isFinalState())

        } else {
            let isAnswerCorrect = isTouchOnRightSide(of: contentView, at: sender.location(in: self.view))
            
            showAnswer(with: isAnswerCorrect)

            guard let _ = viewModel.getCardAfterMovingCard() else {
                lastShowingSubview = NoCardView()
                return
            }

            lastShowingSubview = viewModel.getCurrentSubview()
        }
    }
    
    private func showAnswer(with isAnswerCorrect: Bool) {
        viewModel.addLearningRecordToCurrentCard(isAnswerCorrect: isAnswerCorrect)
        viewModel.moveCard(isAnswerCorrect: isAnswerCorrect)
        
        lastShowingSubview = viewModel.getCurrentSubview()
        let collectionCounts = viewModel.getCollectionCounts()
        updateLabels(collectionCounts: collectionCounts)
    }
    
    private func updateLabels(collectionCounts: (new: Int, relearn: Int, review: Int)) {
        newLabel.text = "\(collectionCounts.new)"
        relearnLabel.text = "\(collectionCounts.relearn)"
        reviewLabel.text = "\(collectionCounts.review)"
    }
    
    private func updateAnswerStateView(isFinalState: Bool) {
        answerTypeStackView.isHidden = !isFinalState
    }
    
    private func isTouchOnRightSide(of view: UIView, at point: CGPoint) -> Bool {
        let midX = view.bounds.midX
        return point.x > midX
    }
    
    
    // MARK: - Actions

    @IBAction func correctAction(_ sender: UIButton) {
        showAnswer(with: true)
    }

    @IBAction func incorrectAction(_ sender: UIButton) {
        showAnswer(with: false)
    }

}




