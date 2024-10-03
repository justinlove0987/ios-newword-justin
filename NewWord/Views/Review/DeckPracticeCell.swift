//
//  JustATestCell.swift
//  NewWord
//
//  Created by justin on 2024/10/3.
//

import UIKit

class DeckPracticeCell: UICollectionViewCell {

    static let reuseIdentifier = String(describing: DeckPracticeCell.self)

    @IBOutlet weak var innerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configureUI(with itemIdentifier: ReviewViewController.ItemIdentifer) {
        innerView.addDefaultBorder()
    }

}
