//
//  PracticeButton.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/9/20.
//

import UIKit

class PracticeButton: UIView, NibOwnerLoadable {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var intervalLabel: UILabel!
    @IBOutlet weak var innerButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNibContent()
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadNibContent()
        setup()
    }
    
    private func setup() {
        innerButton.addTarget(self, action: #selector(touchButton(_:)), for: [.touchDown, .touchDragEnter, .touchDragInside])
        innerButton.addTarget(self, action: #selector(touchCancel(_:)), for: [.touchCancel, .touchDragExit, .touchUpInside, .touchUpOutside, .touchDragOutside])
    }
    
    
    @objc func touchButton(_ sender: UIButton) {
        sender.backgroundColor = UIColor.transition
    }

    @objc func touchCancel(_ sender: UIButton) {
        sender.backgroundColor = UIColor.background
    }
    
    @IBAction func buttonAction(_ sender: UIButton) {
        print("foo - touch button")
    }
    
}
