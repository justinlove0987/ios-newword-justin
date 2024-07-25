//
//  TagView.swift
//  NewWord
//
//  Created by justin on 2024/7/25.
//

import UIKit

class TagView: UIView {

    private var customHeight: CGFloat = 100

    init(customHeight: CGFloat) {
        self.customHeight = customHeight
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override var intrinsicContentSize: CGSize {
        let originalSize = super.intrinsicContentSize

        return CGSize(width: originalSize.width, height: customHeight)
    }

}
