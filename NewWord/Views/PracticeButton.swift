//
//  PracticeButton.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/9/20.
//

import UIKit

class PracticeButton: UIControl, NibOwnerLoadable {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var intervalLabel: UILabel!
    @IBOutlet weak var innerButton: UIButton!

    var status: CDPracticeStatus?

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNibContent()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadNibContent()
    }
}
