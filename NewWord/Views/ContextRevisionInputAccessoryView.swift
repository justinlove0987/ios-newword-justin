//
//  ContextRevisionInputAccessoryView.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/6/4.
//

import UIKit

protocol ContextRevisionInputAccessoryViewDelegate: AnyObject {
    func didTapCleanChineseButton(_ sender: UIView)
    func didAddNewLineAfterPeriodsButton(_ sender: UIView)
    
    func didTapseperateParagraphWithSingleLineActionButton(_ sender: UIView)
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
        delegate?.didTapCleanChineseButton(self)
    }
    
    @IBAction func breakLineAction(_ sender: UIButton) {
        delegate?.didAddNewLineAfterPeriodsButton(self)
    }
    
    
    @IBAction func seperateParagraphWithSingleLineAction(_ sender: UIButton) {
        delegate?.didTapseperateParagraphWithSingleLineActionButton(self)
    }
    
    
}
