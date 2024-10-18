//
//  JustATestCell.swift
//  NewWord
//
//  Created by justin on 2024/10/3.
//

import UIKit

class SingleDeckPracticeCell: UICollectionViewCell {

    @IBOutlet weak var innerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var newLabel: UILabel!
    @IBOutlet weak var relearnLabel: UILabel!
    @IBOutlet weak var reviewLabel: UILabel!

    static let reuseIdentifier = String(describing: SingleDeckPracticeCell.self)

    func configureUI(with itemIdentifier: ReviewViewController.ItemIdentifer) {
        innerView.addDefaultBorder()

        if case let .practiceByDeck(deck) = itemIdentifier {
            newLabel.text = "\(deck.newPractices.count)"
            relearnLabel.text = "\(deck.relearnPractices.count)"
            reviewLabel.text = "\(deck.reviewPractices.count)"

            if let title = deck.name {
                titleLabel.text = title
            }
        }
    }
    
    
    @IBAction func settingAction(_ sender: UIButton) {
    }
    
}
