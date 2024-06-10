//
//  LearningRecordCell.swift
//  NewWord
//
//  Created by justin on 2024/6/10.
//

import UIKit

class LearningRecordCell: UITableViewCell {

    @IBOutlet weak var learnedDateLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var intervalLabel: UILabel!
    @IBOutlet weak var easeLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
