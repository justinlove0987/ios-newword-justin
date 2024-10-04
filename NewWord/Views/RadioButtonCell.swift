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
    
    func configure(row: ReusableRadioButtonCollectionViewController<PracticeType>.Row) {
        titleLabel.text = row.item.title
        
        let imageName = row.isSelected ? "circle.inset.filled" : "circle"
        radioButtonImageView.image = UIImage(systemName: imageName)
    }
    
    func configure(row: ReusableRadioButtonCollectionViewController<SelectDeckItemType>.Row) {
        titleLabel.text = row.item.title
        
        let imageName = row.isSelected ? "circle.inset.filled" : "circle"
        radioButtonImageView.image = UIImage(systemName: imageName)
    }
}
