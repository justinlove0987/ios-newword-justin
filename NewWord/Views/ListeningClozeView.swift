//
//  ListeningClozeView.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/7/26.
//

import UIKit

class ListeningClozeView: UIView, NibOwnerLoadable{
    
    @IBOutlet weak var originalTextLabel: UILabel!
    @IBOutlet weak var translatedTextLabel: UILabel!
    
    private var viewModel: ListeningClozeViewViewModel!
    
    var currentState: CardStateType = .question {
        didSet {
            updateUI()
        }
    }
    
    var card: CDCard?
    
    // MARK: - Lifecycles

    init?(card: CDCard) {
        self.card = card
        super.init(frame: .zero)
        loadNibContent()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNibContent()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadNibContent()
    }
    
    @IBAction func playAction(_ sender: UIButton) {
        
    }
    
    // MARK: - Helpers
    
    private func setup() {
        setupViewModel()
    }
    
    private func setupViewModel() {
        viewModel = ListeningClozeViewViewModel()
        viewModel.card = card
    }
    
    private func setupProperties() {
        originalTextLabel.text = viewModel.getOriginalText()
        translatedTextLabel.text = viewModel.getTranslatedText()
    }
    
    private func updateUI() {
        
    }
    
}

// MARK: - ShowCardsSubviewDelegate

extension ListeningClozeView: ShowCardsSubviewDelegate {
 
    enum CardStateType: Int, CaseIterable {
        case question
        case answer
    }
}
