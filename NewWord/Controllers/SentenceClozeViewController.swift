//
//  SentenceClozeViewController.swift
//  NewWord
//
//  Created by justin on 2024/3/29.
//

import UIKit

private let reuserIdnetifier = "Cell"

class SentenceClozeViewController: UIViewController {
    
    enum AnswerState {
        case answering
        case showingAnswer
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var chineseLabel: UILabel!
    
    private var currentState: AnswerState = .answering {
        didSet {
            updateUI(state: currentState)
        }
    }
    
    private var viewModel = SentenceClozeViewModel()
    
    // MARK: - Life cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(CustomCell.self, forCellReuseIdentifier: reuserIdnetifier)
        viewModel.setup(with:  view.frame.width*0.8)
        chineseLabel.text =  viewModel.getCurrentClozeChinese()?.chinese
        setup()
    }

    // MARK: - Helpers
    
    private func setup() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tap))
        view.addGestureRecognizer(tap)
    }
    
    @objc func tap(_ sender: UITapGestureRecognizer) {
        switch currentState {
        case .answering:
            currentState = .showingAnswer
        case .showingAnswer:
            currentState = .answering
        }
    }
    
    private func updateUI(state: AnswerState) {
        switch currentState {
        case .answering:
            nextQuestion()
            
        case .showingAnswer: // incorrect
            let learningRecord = viewModel.createLearningRecord(isAnswerCorrect: false)
            viewModel.showAnswer()
            
            print(learningRecord)
            
        }
    }
    
    private func nextQuestion() {
        if viewModel.hasNextCard {
            viewModel.nextCard()
            chineseLabel.text =  viewModel.getCurrentClozeChinese()?.chinese
            tableView.reloadData()
        } else {
            let alert = viewModel.createAlertController()
            present(alert, animated: true)
        }
    }
}

extension SentenceClozeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.data.numberOfRowsInSection
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuserIdnetifier, for: indexPath) as! CustomCell
        let words = viewModel.data.wordsForRows[indexPath.row]
        
        cell.delegate = self
        cell.configureStackViewSubViews(clozeWord: viewModel.data.clozeWord,
                                        words: words,
                                        at: indexPath)
        
        return cell
    }
}

extension SentenceClozeViewController: CustomCellDelegate {
    func didCreateTextField(textField: WordTextField) {
        viewModel.textField = textField
    }
    
    func answerCorrect() {
        let learningRecord = viewModel.createLearningRecord(isAnswerCorrect: true)
        print(learningRecord)
        nextQuestion()
    }
}

