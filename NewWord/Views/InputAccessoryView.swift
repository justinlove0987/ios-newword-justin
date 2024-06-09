//
//  InputAccessoryView.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/6/9.
//

import UIKit

class InputAccessoryView: UIView, NibOwnerLoadable {
    
    @IBOutlet weak var textField: UITextField!
    
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
    
}
