//
//  DeckCell.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/5/5.
//

import UIKit

class DeckCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var newLabel: UILabel!
    @IBOutlet weak var relearnLabel: UILabel!
    @IBOutlet weak var reviewLabel: UILabel!
    
    var deck: CDDeck?
    
    var settingAction: (() -> ())?
    
    static let reuseIdentifier = String(describing: DeckCell.self)
    
    // MARK: - Lifecycles
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    // MARK: - Actions
    
    @IBAction func settingAction(_ sender: UIButton) {
        guard let settingAction = settingAction else {
            return
        }
        
        settingAction()
        
    }
    

}
