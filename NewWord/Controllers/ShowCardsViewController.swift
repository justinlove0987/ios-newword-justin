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
}

class ShowCardsViewController: UIViewController, StoryboardGenerated {

    static var storyboardName: String = K.Storyboard.main

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var newLabel: UILabel!
    @IBOutlet weak var relearnLabel: UILabel!
    @IBOutlet weak var reviewLabel: UILabel!
    @IBOutlet weak var rateStackView: UIStackView!
    @IBOutlet weak var answerTypeStackView: UIStackView!
    
    weak var deck: CDDeck?

    private var viewModel = ShowCardsViewControllerViewModel()

    var lastShowingSubview: (any ShowCardsSubviewDelegate)? = NoCardView() {
        willSet {
            layout(newSubview: newValue ?? NoCardView())
        }
    }

    // MARK: - Lifecycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.tintColor = UIColor.title
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        lastShowingSubview = nil
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updatePracticeButtonCornerRadius()
    }

    // MARK: - Helpers

    private func setup() {
        setupViewModel()
        setupProperties()
        setupPracticeButtons()
    }
    
    private func setupViewModel() {
        viewModel.deck = deck
        viewModel.setupPractices()
        
        viewModel.tapAction = { sender in
            self.tapHelper(sender)
        }
        
        viewModel.answerStackViewShouldHidden = { shouldHidden in
            self.answerTypeStackView.isHidden = shouldHidden
            self.rateStackView.isHidden = !shouldHidden
        }
        
        lastShowingSubview = viewModel.getCurrentSubview()
    }

    private func setupProperties() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tap))
        self.view.addGestureRecognizer(tap)

        let collectionCounts = viewModel.getCollectionCounts()
        updateLabels(collectionCounts: collectionCounts)
        
        answerTypeStackView.isHidden = true
        rateStackView.isHidden = false
    }

    private func setupPracticeButtons() {
        guard let statuses = viewModel.deck?.presetc?.standardPreset?.sortedStatuses else {
            return
        }
        
        for i in 0..<statuses.count {
            let status = statuses[i]
            
            let button = PracticeButton()
            
            button.titleLabel.text = status.title
            button.intervalLabel.text = "1.6y"
            button.status = status
            button.addTarget(self, action: #selector(touchButton(_:)), for: [.touchDown, .touchDragEnter, .touchDragInside])
            button.addTarget(self, action: #selector(touchCancel(_:)), for: [.touchCancel, .touchDragExit, .touchUpInside, .touchUpOutside, .touchDragOutside])

            answerTypeStackView.addArrangedSubview(button)
        }
    }
    
    private func updatePracticeButtonCornerRadius() {
        let screenCornerRadius: CGFloat = 44
        let safeAreaInsetBottom = view.safeAreaInsets.bottom
        let cornerRadius = screenCornerRadius - safeAreaInsetBottom
        
        for i in 0..<answerTypeStackView.arrangedSubviews.count {
            let button = answerTypeStackView.arrangedSubviews[i]
            let isFirstButton = i == 0
            let isLastButton = i + 1 == answerTypeStackView.arrangedSubviews.count
            
            if isFirstButton {
                button.addDefaultBorder(cornerRadius: cornerRadius, maskedCorners: [.layerMinXMaxYCorner])
            } else if isLastButton {
                button.addDefaultBorder(cornerRadius: cornerRadius, maskedCorners: [.layerMaxXMaxYCorner])
            } else {
                button.addDefaultBorder(cornerRadius: 0)
            }
        }
    }

    private func layout(newSubview: any ShowCardsSubviewDelegate) {
        if let oldClozeView = lastShowingSubview as? ClozeView {
            oldClozeView.customInputView.textField.resignFirstResponder()
        }

        lastShowingSubview?.removeFromSuperview()

        self.view.addSubview(newSubview)
        
        newSubview.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            newSubview.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            newSubview.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            newSubview.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            newSubview.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
        ])
        
        view.layoutIfNeeded()
        
        updateAnswerStateView(isFinalState: newSubview.isFinalState())
    }

    @objc func tap(_ sender: UITapGestureRecognizer) {
        tapHelper(sender)
    }

    private func tapHelper(_ sender: UITapGestureRecognizer) {
        let hasNextState = lastShowingSubview?.hasNextState()

        if let hasNextState, hasNextState {
            lastShowingSubview?.nextState()

            guard let isFinalState = lastShowingSubview?.isFinalState() else {
                return
            }

            updateAnswerStateView(isFinalState: isFinalState)

        } else {
            if let practiceButton = touchedAnswerButton(sender: sender) {
                guard let statusType = practiceButton.status?.type else { return }

                showAnswer(with: statusType)

            } else {
                let statusType: PracticeStandardStatusType = isTouchOnRightSide(of: contentView, at: sender.location(in: self.view)) ? .easy : .again
                showAnswer(with: statusType)
            }

            guard let _ = viewModel.getCardAfterMovingCard() else {
                lastShowingSubview = NoCardView()
                return
            }

            lastShowingSubview = viewModel.getCurrentSubview()
        }
    }
    
    private func showAnswer(with userPressedStatusType: PracticeStandardStatusType) {
        viewModel.addLearningRecordToCurrentCard(userPressedStatusType: userPressedStatusType)
        viewModel.moveCard(userPressedStatusType: userPressedStatusType)

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
        if isFinalState && !viewModel.hasNoCard() {
            answerTypeStackView.isHidden = true
            rateStackView.isHidden = false
            
        } else {
            answerTypeStackView.isHidden = !isFinalState
            rateStackView.isHidden = isFinalState
        }
    }
    
    private func isTouchOnRightSide(of view: UIView, at point: CGPoint) -> Bool {
        let midX = view.bounds.midX
        return point.x > midX
    }

    private func touchedAnswerButton(sender: UITapGestureRecognizer) -> PracticeButton? {
        for subview in answerTypeStackView.arrangedSubviews {
            let touchPoint = sender.location(in: subview)
            if subview.bounds.contains(touchPoint) {
                if let subview = subview as? PracticeButton {
                    return subview
                }
            }
        }

        return nil
    }

    
    // MARK: - Actions

//    @IBAction func correctAction(_ sender: UIButton) {
//        showAnswer(with: true)
//    }
//
//    @IBAction func incorrectAction(_ sender: UIButton) {
//        showAnswer(with: false)
//    }

    @objc func touchButton(_ sender: UIButton) {
        sender.backgroundColor = UIColor.transition
    }

    @objc func touchCancel(_ sender: UIButton) {
        sender.backgroundColor = UIColor.background
    }

    deinit {
        print("foo - ShowCardsViewController deinit")
    }

}




