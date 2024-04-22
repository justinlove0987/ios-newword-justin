//
//  WordTextField.swift
//  NewWord
//
//  Created by justin on 2024/4/1.
//

import UIKit

class WordTextField: UITextField {

    var word: Word

    init(with word: Word, frame: CGRect) {
        self.word = word
        super.init(frame: frame)

    }

    override init(frame: CGRect) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
