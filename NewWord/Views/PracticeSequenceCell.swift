//
//  PracticeSequenceCollectionViewCell.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/8/26.
//

import UIKit

class PracticeSequenceCell: UICollectionViewCell {
    
    static let reuseIdentifier = String(describing: PracticeSequenceCell.self)
    
    @IBOutlet weak var backgroundCoverView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundCoverView.addDefaultBorder(cornerRadius: 5)
        
        
    }

}
