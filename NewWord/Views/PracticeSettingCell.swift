//
//  PracticeSettingCell.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/8/26.
//

import UIKit

class PracticeSettingCell: UICollectionViewCell {
    
    static let reuseIdentifier = String(describing: PracticeSettingCell.self)
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descriptionStackView: UIStackView!
    @IBOutlet weak var switchButton: UISwitch!
    @IBOutlet weak var chevronImageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var radioButtonImageView: UIImageView!
    
    func configure(row: PracticeSettingViewController.Row) {
        hideStackViewArrangedSubviews()
        
        titleLabel.text = row.title
        imageView.image = UIImage(systemName: row.sfSymbolName)
        
        
        switch row.cellType {
        case .navigation:
            chevronImageView.isHidden = false
            
        case .information:
            descriptionLabel.isHidden = false
            
            
        case .toggleSwitch:
            switchButton.isHidden = false
        }
    }
    
    func hideStackViewArrangedSubviews() {
        for subview in descriptionStackView.arrangedSubviews {
            subview.isHidden = true
        }
    }

}
