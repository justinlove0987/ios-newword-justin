//
//  DeckSettingInputCell.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/5/6.
//

import UIKit

class DeckSettingInputCell: UITableViewCell {
    
    static let reuseIdentifier  = String(describing: DeckSettingInputCell.self)
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var inputTextField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    static func createCell(tableView: UITableView, indexPath: IndexPath, title: String, inputText: String) -> Self {
        let cell = tableView.dequeueReusableCell(withIdentifier: Self.reuseIdentifier, for: indexPath) as! Self
        cell.titleLabel.text = title
        cell.inputTextField.placeholder = inputText
        return cell
    }

}
