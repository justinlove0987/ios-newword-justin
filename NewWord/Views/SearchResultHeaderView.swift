//
//  SearchResultHeaderView.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/10/15.
//

import UIKit

protocol SearchResultHeaderViewDelegate: AnyObject {
    func searchResultHeaderViewDidTapRecordButton(_ headerView: SearchResultHeaderView)
}

class SearchResultHeaderView: UICollectionReusableView {
    
    static let reuseIdentifier = String(describing: SearchResultHeaderView.self)
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    
    weak var delegate: SearchResultHeaderViewDelegate?
    
    var recordCallback: (() ->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func updateUI(title: String?) {
        titleLabel.text = title
    }
    
    @IBAction func recordAction(_ sender: UIButton) {
        recordCallback?()
        delegate?.searchResultHeaderViewDidTapRecordButton(self)
    }
}
