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
    @IBOutlet weak var uploadedDateLabel: UILabel!
    @IBOutlet weak var innerView: UIView!
    
    @IBOutlet weak var cefrView: UIView!
    @IBOutlet weak var cefrLabel: UILabel!
    
    var imageDidSetCallback: ((UIImage) -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        innerView.addDefaultBorder(cornerRadius: 15)
    }
    
    func configure(_ article: PracticeTagArticle.Copy) {
        titleLabel.text = article.title
        contentLabel.text = article.content
        uploadedDateLabel.text = article.formattedUploadedDate
        
        conifgureCEFRLabel(article)
    }
    
    func conifgureCEFRLabel(_ article: PracticeTagArticle.Copy) {
        cefrView.addDefaultBorder(cornerRadius: 5)
        cefrView.isHidden = article.cefrType == nil
        cefrLabel.text = article.cefr?.title
    }
}
