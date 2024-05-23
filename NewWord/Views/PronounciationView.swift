//
//  PronounciationView.swift
//  NewWord
//
//  Created by justin on 2024/5/21.
//

import UIKit

class PronounciationView: UIView, NibOwnerLoadable {

    @IBOutlet weak var aLabel: UILabel!
    @IBOutlet weak var bLabel: UILabel!
    @IBOutlet weak var cLabel: UILabel!
    
    enum CardStateType: Int {
        case aState
        case bState
        case cState
    }
    
    var currentState: CardStateType = .aState {
        didSet {
            switch currentState {
            case .aState:
                aLabel.isHidden = false
                bLabel.isHidden = true
                cLabel.isHidden = true
            case .bState:
                aLabel.isHidden = true
                bLabel.isHidden = false
                cLabel.isHidden = true
            case .cState:
                aLabel.isHidden = true
                bLabel.isHidden = true
                cLabel.isHidden = false
            }
        }
    }
    
    var currentStateRawValue: Int = 0
    
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

extension PronounciationView: ShowCardsSubviewDelegate {
    
    func hasNextState() -> Bool {
        let rawValue = currentState.rawValue
        let nextState = CardStateType(rawValue: rawValue+1)
        
        guard let nextState else { return false }
        
        
        return true
    }
    
    func nextState(){
        let rawValue = currentState.rawValue
        let nextState = CardStateType(rawValue: rawValue+1)
        
        guard let nextState else { return }
        
        currentState = nextState
    }

}
