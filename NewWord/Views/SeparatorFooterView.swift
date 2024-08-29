//
//  SeparatorFooterView.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/8/26.
//

import UIKit

class SeparatorFooterView: UICollectionReusableView {
    
    static let reuseIdentifier = String(describing: SeparatorFooterView.self)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        let separator = UIView()
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.backgroundColor = UIColor.transition
        
        addSubview(separator)
        
        NSLayoutConstraint.activate([
            separator.heightAnchor.constraint(equalToConstant: 8),
            separator.leadingAnchor.constraint(equalTo: leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: trailingAnchor),
            separator.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

