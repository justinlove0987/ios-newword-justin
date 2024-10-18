//
//  PracticeSettingCell.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/8/26.
//

import UIKit

enum PracticeSettingCellItemType: Int, CaseIterable {
    case practiceType
    case deck
    case threshold
    
    var cellType: PracticeSettingCell.CellType {
        switch self {
        case .practiceType, .deck, .threshold:
            return .navigation
        }
    }
    
    var title: String {
        switch self {
        case .practiceType:
            return "練習種類"
        case .deck:
            return "練習牌組"
        case .threshold:
            return "進入下一階段條件"
        }
    }
    
    var sfSymbolName: String {
        switch self {
        case .practiceType:
            return "list.bullet"
        case .deck:
            return "sparkles.rectangle.stack"
        case .threshold:
            return "flag.checkered.circle"
        }
    }
}

protocol PracticeSettingCellProtocol {
    var itemTypes: [PracticeSettingCellItemType] { get set }
}

class PracticeSettingCell: UICollectionViewCell {
    
    static let reuseIdentifier = String(describing: PracticeSettingCell.self)
    
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
