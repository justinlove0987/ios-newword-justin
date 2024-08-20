//
//  PracticeModeSelectorView.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/8/20.
//

import UIKit

protocol PracticeModeSelectorViewDelegate: AnyObject {
    func practiceModeSelectorViewDidTapPracticeButton(_ selectorView: PracticeModeSelectorView)
}

class PracticeModeSelectorView: UIView, NibOwnerLoadable {
    
    weak var delegate: PracticeModeSelectorViewDelegate?
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var selectedModeImageView: UIImageView!
    @IBOutlet weak var practiceButtonStackView: UIStackView!
    @IBOutlet weak var practiceButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    deinit {
        print("foo - deinit NoCardView")
    }
    
    private func commonInit() {
        loadNibContent()
        playButton.isHidden = true
        selectedModeImageView.isHidden = true
    }
    
    @IBAction func practiceButtonAction(_ sender: UIButton) {
        delegate?.practiceModeSelectorViewDidTapPracticeButton(self)
    }
}
