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

    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    
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
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNibContent()
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadNibContent()
        setup()
    }
    
    @IBAction func playAction(_ sender: UIButton) {
        
    }
    
    // MARK: - Helpers
    
    private func setup() {
        setupViewModel()
        setupProperties()
    }
    
    private func setupViewModel() {
        viewModel = ListeningClozeViewViewModel()
        viewModel.card = card
    }
    
    private func setupProperties() {
        originalTextLabel.text = viewModel.getOriginalText()
        translatedTextLabel.text = viewModel.getTranslatedText()

        layoutIfNeeded()
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
