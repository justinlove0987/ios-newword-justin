//
//  PracticeSettingCell.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/8/26.
//

import UIKit

class PracticeSettingCell: UICollectionViewCell {
    
    struct CellContent: Hashable {
        let title: String?
        let description: String?
        let imageName: String?
        let cellType: CellType
    }
    
    enum CellType: Int, CaseIterable {
        case navigation
        case information
        case toggleSwitch
    }
    
    static let reuseIdentifier = String(describing: PracticeSettingCell.self)
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descriptionStackView: UIStackView!
    @IBOutlet weak var switchButton: UISwitch!
    @IBOutlet weak var chevronImageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var radioButtonImageView: UIImageView!
    
    func updateUI(content: CellContent) {
        hideStackViewArrangedSubviews()
        updateCellType(content.cellType)
        
        self.titleLabel.text = content.title
        self.descriptionLabel.text = content.description
        
        if let imageName = content.imageName {
            self.imageView.image = UIImage(systemName: imageName)
        }
    }
    
    func updateCellType(_ type: CellType) {
        switch type {
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
