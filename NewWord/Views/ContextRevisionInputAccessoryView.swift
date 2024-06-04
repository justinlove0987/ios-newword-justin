//
//  ContextRevisionInputAccessoryView.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/6/4.
//

import UIKit

protocol ContextRevisionInputAccessoryViewDelegate: AnyObject {
    func didTapCleanChineseButton()
}

class ContextRevisionInputAccessoryView: UIView, NibOwnerLoadable {
    
    weak var delegate: ContextRevisionInputAccessoryViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        loadNibContent()
    }
    
    @IBAction func cleanChineseAction(_ sender: UIButton) {
        delegate?.didTapCleanChineseButton()
    }
    
}
