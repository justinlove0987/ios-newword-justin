//
//  RadioButtonCell.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/8/27.
//

import UIKit

class RadioButtonCell: UICollectionViewCell {
    
    static let reuseIdentifier = String(describing: RadioButtonCell.self)
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var radioButtonImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
