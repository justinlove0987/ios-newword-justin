//
//  ExploreCell.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/8/1.
//

import UIKit

class ExploreCell: UICollectionViewCell {
    
    static let reuseIdentifier = String(describing: ExploreCell.self)
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    
    @IBOutlet weak var innerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        innerView.addDefaultBorder(cornerRadius: 15)
    }
    
    func updateUI(_ article: FSArticle) {
        titleLabel.text = article.title
        contentLabel.text = article.content
    }

}
