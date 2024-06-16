//
//  ContextLabel.swift
//  NewWord
//
//  Created by justin on 2024/6/15.
//

import UIKit

class ContextLabel: UILabel {

    enum LabelType {
        case word
        case punctuation
        case newline
    }

    var isSelected: Bool = false {
        didSet {
            if isSelected {
                backgroundColor = .blue
            } else {
                backgroundColor = .clear
            }

        }
    }

    var labelType: LabelType = .word {
        didSet {
            updateUI()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func updateUI() {
        textAlignment = .left
        font = UIFont.systemFont(ofSize: Preference.fontSize)

        switch labelType {
        case .word:
            isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction))
            self.addGestureRecognizer(tap)

        case .punctuation, .newline:
            isUserInteractionEnabled = false
        }
    }

    @objc func tapAction(_ sender: UITapGestureRecognizer) {
        isSelected.toggle()
    }
}

