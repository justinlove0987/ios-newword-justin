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
    
    func configure(row: PracticeSettingViewController.Row, data: CDPractice) {
        hideStackViewArrangedSubviews()
        
        titleLabel.text = row.title
        imageView.image = UIImage(systemName: row.sfSymbolName)
        
        configureDescriptionLabel(row: row, data: data)
        configureCellType(row: row)
    }
    
    func configureDescriptionLabel(row: PracticeSettingViewController.Row, data: CDPractice) {
        guard let preset = data.preset?.standardPreset else { return }

        var description: String
        
        switch row {
        case .practiceType:
            guard let title = data.type?.title else { return }

            description = title

//        case .firstPracticeLearningPhase:
//            description = String(preset.firstPracticeLearningPhase)
//            
//        case .firstPracticeGraduationInterval:
//            description = String(preset.firstPracticeGraduationInterval)
//            
//        case .firstPracticeEasyInterval:
//            description = String(preset.firstPracticeEasyInterval)
//            
//        case .forgotRelearningPhase:
//            description = String(preset.forgetPracticeRelearningSteps)
//            
//        case .forgotGraduationInterval:
//            description = String(preset.forgetPracticeInterval)
            
        case .initialEase:
            description = String(preset.firstPracticeEase)
            
        case .followPreviousPractice:
            description = ""
            
        case .practiceCompletionRules:
            description = ""

        default:
            description = ""
        }
        
        descriptionLabel.text = description
        
    }
    
    func configureCellType(row: PracticeSettingViewController.Row) {
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
