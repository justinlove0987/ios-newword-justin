//
//  NoCardView.swift
//  NewWord
//
//  Created by justin on 2024/5/22.
//

import UIKit

class NoCardView: UIView, NibOwnerLoadable {
    
    enum CardStateType: Int, CaseIterable {
        case none
    }
    
    var currentState: CardStateType = .none

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

extension NoCardView: ShowCardsSubviewDelegate {}
