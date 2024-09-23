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
    @IBOutlet weak var tagExistsView: UIView!
    
    
    var imageDidSetCallback: ((UIImage) -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        innerView.addDefaultBorder(cornerRadius: 15)
    }
    
    func configure(_ article: CDPracticeArticle) {
        titleLabel.text = article.title
        contentLabel.text = article.content
        uploadedDateLabel.text = article.formattedUploadedDate
        
        conifgureCEFRLabel(article)
        configureTagExistsView(article)
    }
    
    func conifgureCEFRLabel(_ article: CDPracticeArticle) {
        cefrView.addDefaultBorder(cornerRadius: 5)
        cefrView.isHidden = article.cefr! == .none
        cefrLabel.text = article.cefr?.title
    }
    
    func configureTagExistsView(_ article: CDPracticeArticle) {
        if let tagCounts = article.userGeneratedArticle?.userGeneratedContextTagSet?.count
        {
            let hasAtLeastOneTag = tagCounts > 0
            
            tagExistsView.isHidden = !hasAtLeastOneTag
            tagExistsView.addDefaultBorder(cornerRadius: 5)
        }
    }
}
