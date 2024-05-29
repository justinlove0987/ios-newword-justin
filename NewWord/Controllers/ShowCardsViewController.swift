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
            
            guard let _ = viewModel.nextCard() else {
                lastShowingSubview = NoCardView()
                view.layoutSubviews()
                return
            }
            
            lastShowingSubview = viewModel.getCurrentSubview()
        }
    }

    @IBAction func correctAction(_ sender: UIButton) {
        viewModel.addLearningRecordToCurrentCard(isAnswerCorrect: true)
        
        lastShowingSubview = viewModel.getCurrentSubview()
        
        
        
//        filteredCards[currentCardIndex].learningRecords.append(record)

        // 一方面要對正在用的資料進行操作 另一方面要對本地端的資料進行操作
        // 檢查是否要繼續放入filtered card，不要就從filteredcard中剔除
        // 先訂一個順序就好 new review relearn
        // 怎麼讓new學完後再學下一個review？

//        if record.dueDate <= Date() {
//
//        }
    }

    @IBAction func incorrectAction(_ sender: UIButton) {

    }
}




