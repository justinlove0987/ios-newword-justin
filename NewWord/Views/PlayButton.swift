//
//  PlayButton.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/7/27.
//

import UIKit

class PlayButton: UIControl, NibOwnerLoadable {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var overlayViewTrailingConstraint: NSLayoutConstraint!
    
    override var isSelected: Bool {
        didSet {
            
        }
    }
    
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
        contentView.addDefaultBorder(cornerRadius: 5)
        overlayViewTrailingConstraint.constant = 80
    }
    
    func applyOverlayAnimation(duration: TimeInterval, color: UIColor) {
        imageView.image = UIImage(systemName: "pause.fill")
        self.layoutIfNeeded()
        
        overlayViewTrailingConstraint.constant = 0
        
        // 開始動畫
        UIView.animate(withDuration: duration) {
            self.layoutIfNeeded()
        }
    }
}
