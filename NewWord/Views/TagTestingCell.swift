//
//  TagTestingCell.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/7/19.
//

import UIKit

class TagTestingCell: UITableViewCell {

    @IBOutlet var secondButtons: [UIButton]!
    @IBOutlet var thirdButtons: [UIButton]!
    @IBOutlet var forthButtons: [UIView]!
    
    @IBOutlet weak var forthStackView: UIStackView!
    
    private var isOpen = true
    
    @IBOutlet weak var secondStackVIew: UIStackView!
    
    var reload: (() ->())?
    var beginUpdate: (() ->())?
    var endUpdate: (() ->())?
    
    @IBAction func hideSecondButtonAction(_ sender: UIButton) {
        for button in self.secondButtons {
            self.beginUpdate?()
            UIView.animate(withDuration: 0.3) {
                button.isHidden.toggle()
            }
            self.endUpdate?()
        }
    }
    
    
    @IBAction func hideThirdButtonAction(_ sender: UIButton) {
        animate3(thirdButtons)
    }
    
    @IBAction func hideForthButtonAction(_ sender: UIButton) {
        animate3(forthButtons)
    }
    
    @IBAction func addForthViewAction(_ sender: UIButton) {
        let button = UIButton()
        button.setTitle("New Button", for: .normal)
        button.backgroundColor = .gray
        
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: 34),
        ])
    
        forthButtons.append(button)
        
        button.setContentHuggingPriority(UILayoutPriority(210), for: .vertical)
        self.forthStackView.insertArrangedSubview(button, at: self.forthStackView.subviews.count - 1)
        button.isHidden = true
        
        beginUpdate?()
        UIView.animate(withDuration: 0.3) {
            button.isHidden = false
        }
        endUpdate?()
    }
    
    
    // Ｘ：beginUpdate在UIview.animate中會有奇怪的效果
    private func animate3(_ views: [UIView]) {
        
        if isOpen {
            for view in views {
                for subview in view.subviews {
                    subview.isHidden.toggle()
                    subview.alpha = 0
                }
                
                self.beginUpdate?()
                UIView.animate(withDuration: 0.3) {
                    view.isHidden.toggle()
                }
                self.endUpdate?()
            }
        } else {
            for view in views {
                self.beginUpdate?()
                UIView.animate(withDuration: 0.3) {
                    view.isHidden.toggle()
                } completion: { isComplete in
                    if isComplete {
                        for subview in view.subviews {
                            UIView.animate(withDuration: 0.1) {
                                subview.isHidden.toggle()
                                subview.alpha = 1
                            }
                        }
                    }
                }
                self.endUpdate?()
            }
        }

        
        isOpen.toggle()
    }
    
    
    
    // 有view.isHidden在beginUpdate、endUpdate間的狀況：收起時會有部分區塊較晚收，打開時正常
    private func animate2(_ views: [UIView]) {
        for view in views {
            for subview in view.subviews {
                subview.isHidden.toggle()
            }
            
            self.beginUpdate?()
            view.isHidden.toggle()
            self.endUpdate?()
        }
        
        self.reload?()
    }
    
    // 最後reload的狀況：收起時會瞬間收掉，打開時一個一個出現
    private func animate1(_ views: [UIView]) {
        for view in views {
            for subview in view.subviews {
                subview.isHidden.toggle()
            }
            
            
            view.isHidden.toggle()
        }
        
        isOpen.toggle()
        
        self.reload?()
    }
    
    
    
    private func animate(views: [UIView], index: Int) {
        guard index < views.count else { return }
        
        var index = index
        
        let i = views.count - 1 - index
        
        UIView.animate(withDuration: 0.2) {
            let view = views[i]
            
//            self.beginUpdate?()
            view.isHidden.toggle()
//            self.endUpdate?()
            
            index += 1
            
            
        } completion: { isComplete in
            self.reload?()
            
            if isComplete {
                self.animate(views: views, index: index)
                
            }
        }
    }
}
