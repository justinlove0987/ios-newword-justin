//
//  PronounciationView.swift
//  NewWord
//
//  Created by justin on 2024/5/21.
//

import UIKit

class PronounciationView: UIView, NibOwnerLoadable {

    @IBOutlet weak var myLabel: UILabel!
    
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
