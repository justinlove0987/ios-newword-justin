//
//  NumberTagLabel.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/7/4.
//

import UIKit

class NumberTagLabel: UILabel {

    let contentLabel: UILabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func setupContentLabel() {
        self.addSubview(contentLabel)
        
        self.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        contentLabel.text = self.text
        contentLabel.font = UIFont.systemFont(ofSize: self.font.pointSize - 7, weight: .medium)
        contentLabel.textAlignment = .center
        contentLabel.textColor = .clozeBlueText
        contentLabel.frame = self.bounds
        contentLabel.backgroundColor = UIColor.clozeBlueNumber

        self.text = String(repeating: " ", count: self.text?.count ?? 0)
        let path =  UIBezierPath(roundedRect: self.bounds, byRoundingCorners: .topLeft, cornerRadii: CGSize(width: 3, height: 3))
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath

        self.layer.mask = maskLayer
        self.backgroundColor = UIColor.clozeBlueNumber
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
