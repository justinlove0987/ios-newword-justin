//
//  PracticeThresholdCell.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/10/17.
//

import UIKit

class PracticeThresholdCell: UICollectionViewCell {
    
    static let reuseIdentifier = String(describing: PracticeThresholdCell.self)
    
    @IBOutlet weak var thresholdSettingsButton: UIButton!
    @IBOutlet weak var thresholdValueTextField: UITextField!
    
    func updateUI(threshold: CDPracticeThresholdRule) {
        thresholdSettingsButton.setTitle(threshold.conditionType?.title, for: .normal)
        thresholdValueTextField.text = String(threshold.conditionValue)
    }
    
    @IBAction func thresholdSettingsAction(_ sender: UIButton) {
        
        
    }
    
}
