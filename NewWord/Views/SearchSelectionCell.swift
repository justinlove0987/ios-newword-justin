//
//  SearchSelectionCell.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/6/27.
//

import UIKit

class SearchSelectionCell: UITableViewCell {
    
    static let reuseIdentifier = "SearchSelectionCell"
    
    @IBOutlet weak var deckNameLabel: UILabel!
    @IBOutlet weak var checkmarkImageView: UIImageView!
    
    override var isSelected: Bool {
        didSet {
            let imageName = isSelected ? "checkmark.square.fill" : "square"

            checkmarkImageView.image = UIImage(systemName: imageName)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func updateUI(deck: CDDeck) {
        deckNameLabel.text = deck.name
    }
    
}
