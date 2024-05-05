//
//  DeckCell.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/5/5.
//

import UIKit

class DeckCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    
    static let reuseIdentifier = String(describing: DeckCell.self)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
