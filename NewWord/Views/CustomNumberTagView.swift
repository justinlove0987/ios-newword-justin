//
//  CustomNumberTagView.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/7/5.
//

import UIKit

class CustomNumberTagView: UIView, NibOwnerLoadable {
    
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var spacingView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNibContent()
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadNibContent()
        setup()
    }
    
    func setup() {
        numberLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        numberLabel.textAlignment = .center
        numberLabel.textColor = UIColor.clozeBlueText
    }
}
