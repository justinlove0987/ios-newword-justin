//
//  PracticeClozeView.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/9/27.
//

import UIKit

class PracticeClozeView: UIView, NibOwnerLoadable {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var clozeLabel: UILabel!
    
    var practice: CDPractice? {
        didSet {
            updateUI()
        }
    }
    
    var currentState: CardStateType = .question {
        didSet {
            updateUI()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNibContent()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadNibContent()
    }
    
    private func updateUI() {
        guard let article = practice?.serverProviededContent?.article,
              let cloze = practice?.userGeneratedContent?.userGeneratedContextTag else {
            return
        }
        
        textView.text = article.text
        clozeLabel.text = cloze.text
        
        switch currentState {
        case .question:
            clozeLabel.isHidden = true
            
        case .answer:
            clozeLabel.isHidden = false
        }
    }
}

extension PracticeClozeView: ShowCardsSubviewDelegate {
    enum CardStateType: Int, CaseIterable {
        case question
        case answer
    }
}
