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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    private func updateUI() {
        
    }
    
    @IBAction func thresholdSettingsAction(_ sender: UIButton) {
        
        
    }
    
}
