//
//  PracticeSettingHeaderView.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/8/26.
//

import UIKit

class PracticeSettingHeaderView: UICollectionReusableView {
    
    static let reuseIdentifier = String(describing: PracticeSettingHeaderView.self)

    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(with title: String) {
        titleLabel.text = title
    }
    
}
