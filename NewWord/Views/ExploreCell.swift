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
    
    var imageDidSetCallback: ((UIImage) -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        innerView.addDefaultBorder(cornerRadius: 15)
    }
    
    func updateUI(_ article: FSArticle) {
        titleLabel.text = article.title
        contentLabel.text = article.content
        uploadedDateLabel.text = article.formattedUploadedDate
        
        if let image = article.image {
            self.imageView.image = image
        } else {
            fetchImage(article)
        }
    }

    func fetchImage(_ article: FSArticle) {
        FirestoreManager.shared.getImage(for: article.imageId) { result in
            switch result {
            case .success(let image):
                DispatchQueue.main.async {
                    self.imageView.image = image
                    self.imageDidSetCallback?(image)
                }
            case .failure(_):
                self.imageView.image = UIImage(named: "loading")!
            }
        }
    }

}
