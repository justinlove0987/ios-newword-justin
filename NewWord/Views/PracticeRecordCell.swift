//
//  PracticeRecordCell.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/10/16.
//

import UIKit

class PracticeRecordCell: UICollectionViewCell {
    
    static let reuseIdentifier = String(describing: PracticeRecordCell.self)
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var rateLabel: UILabel!
    @IBOutlet weak var intervalLabel: UILabel!
    @IBOutlet weak var easeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func updateUI(_ item: PracticeRecordViewController.Item) {
        dateLabel.text = item.formattedLearnedDate
        stateLabel.text = item.state
        rateLabel.text = item.rate
        intervalLabel.text = item.interval
        easeLabel.text = item.ease
    }

}
