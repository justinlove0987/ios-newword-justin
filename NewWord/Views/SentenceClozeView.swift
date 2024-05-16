//
//  SentenceClozeView.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/5/16.
//

import UIKit

class SentenceClozeView: UIView {
    
    @IBOutlet weak var chineseLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
//    private var viewModel: SentenceClozeViewModel!
//    private var card: Card!
    
    static var nib: UINib {
           UINib(nibName: String(describing: self), bundle: Bundle(for: self))
       }
    
    init(frame: CGRect, viewModel: SentenceClozeViewModel, card: Card) {
        super.init(frame: frame)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
         super.init(coder: aDecoder)
         commonInit()
     }
    
    private func commonInit() {
        guard let views = Self.nib.instantiate(withOwner: self, options: nil) as? [UIView],
              let contentView = views.first else {
            fatalError("Fail to load \(self) nib content")
        }
        
        self.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        contentView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
}
