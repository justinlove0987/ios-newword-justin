//
//  SettingCell.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/7/28.
//

import UIKit

class SettingCell: UITableViewCell {
    
    static let reuseIdentifier = "SettingCell"
    
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
