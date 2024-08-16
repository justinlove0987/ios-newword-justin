//
//  ArticlePlayButton.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/8/16.
//

import UIKit

class ArticlePlayButtonView: UIView, NibOwnerLoadable {
    
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
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
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        
        return playButton
    }
}


