//
//  PracticeCompletionCollectionViewCell.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/9/30.
//

import UIKit

class PracticeCompletionCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var conditionLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    static let reuseIdentifier = String(describing: PracticeCompletionCollectionViewCell.self)
    
    var itemIdentifier: PracticeCompletionViewController.Row?
    
    func updateUI() {
        guard let rule = itemIdentifier?.practiceThreshold else {
            return
        }
        
        conditionLabel.text = rule.conditionType?.title
        textField.text = "\(rule.conditionValue)"
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        textField.delegate = self
        textField.keyboardType = .numberPad
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text,
              let value = Int(text),
              let rule = itemIdentifier?.practiceThreshold else {
            return
        }
        
        rule.conditionValue = value.toInt64
        
        updateUI()
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // 檢查點擊位置是否在 textField 上
        if self.point(inside: point, with: event) {
            return textField // 將所有點擊視為 textField 的點擊
        }
        return super.hitTest(point, with: event)
    }
}



extension PracticeCompletionCollectionViewCell: UITextFieldDelegate {
    
}
