//
//  SentenceClozeView.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/5/16.
//

import UIKit

private let reuserIdnetifier = "Cell"

class SentenceClozeView: UIView, NibOwnerLoadable {
    
    enum CardStateType: Int, CaseIterable {
        case question
        case answer
    }

    @IBOutlet weak var chineseLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    private var viewModel: SentenceClozeViewModel!
    private var card: CDCard!
    
    var currentState: CardStateType = .question {
        didSet {
            switch currentState {
            case .question:
                viewModel.textField?.text = ""
            case .answer:
                viewModel.textField?.text = viewModel.getCurrentClozeChinese()?.chinese
            }
        }
    }

    init(viewModel: SentenceClozeViewModel, card: CDCard) {
        self.viewModel = viewModel
        self.card = card
        super.init(frame: .zero)
        commonInit()
        setup()
    }


    private func setup() {
        tableView.register(CustomCell.self, forCellReuseIdentifier: reuserIdnetifier)
        viewModel.setup(with: tableView.frame.width)
        chineseLabel.text =  viewModel.getCurrentClozeChinese()?.chinese
    }

    private func setupDataSource() {

    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
         super.init(coder: aDecoder)
         commonInit()
     }

    private func commonInit() {
        loadNibContent()
    }
}

extension SentenceClozeView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.data.numberOfRowsInSection
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuserIdnetifier, for: indexPath) as! CustomCell
        let words = viewModel.data.wordsForRows[indexPath.row]

        cell.delegate = self
        cell.configureStackViewSubViews(clozeWord: viewModel!.data.clozeWord,
                                        words: words,
                                        at: indexPath)

        return cell
    }
}

extension SentenceClozeView: CustomCellDelegate {
    func didCreateTextField(textField: WordTextField) {
        viewModel.textField = textField
    }

    func answerCorrect() {
    }
}

extension SentenceClozeView: ShowCardsSubviewDelegate {}
