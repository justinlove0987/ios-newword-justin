//
//  ShowPracticesViewController.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/9/17.
//

import UIKit

class ShowPracticesViewController: UIViewController {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var newLabel: UILabel!
    @IBOutlet weak var relearnLabel: UILabel!
    @IBOutlet weak var reviewLabel: UILabel!
    @IBOutlet weak var rateStackView: UIStackView!
    @IBOutlet weak var answerTypeStackView: UIStackView!
    
    weak var deck: CDDeck?
    
    private var viewModel = ShowPracticesViewControllerViewModel()
    
    // MARK: - Life cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    // MARK: - Helpers
    
    private func setup() {
        
    }
    
    private func setupViewModel() {
        viewModel.deck = deck
        
        
//        viewModel.setupCards()
//        
//        viewModel.tapAction = { sender in
//            self.tapHelper(sender)
//        }
//        
//        viewModel.answerStackViewShouldHidden = { shouldHidden in
//            self.answerTypeStackView.isHidden = shouldHidden
//            self.rateStackView.isHidden = !shouldHidden
//        }
//        
//        lastShowingSubview = viewModel.getCurrentSubview()
    }

}
