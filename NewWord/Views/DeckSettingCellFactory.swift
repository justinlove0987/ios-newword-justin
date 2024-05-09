//
//  DeckSettingFactory.swift
//  NewWord
//
//  Created by justin on 2024/5/7.
//

import UIKit

struct DeckSettingCellFactory {

    let tableView: UITableView
    let indexPath: IndexPath

    init(tableView: UITableView, indexPath: IndexPath) {
        self.tableView = tableView
        self.indexPath = indexPath
    }
    
    init(tableView: UITableView) {
        self.tableView = tableView
        self.indexPath = IndexPath()
    }

    func createInputCell(title: String, input: String) -> DeckSettingInputCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DeckSettingInputCell.reuseIdentifier, for: indexPath) as! DeckSettingInputCell
        cell.titleLabel.text = title
        cell.inputTextField.text = input
        return cell
    }

    func createSelectionCell(title: String, selection: String) -> DeckSettingSelectionCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DeckSettingSelectionCell.reuseIdentifier, for: indexPath) as! DeckSettingSelectionCell
        cell.titleLabel.text = title
        cell.selectionLabel.text = selection
        return cell
    }
    
    func getCellInput() -> String {
        let cell = tableView.cellForRow(at: indexPath) as! DeckSettingInputCell
        return cell.inputTextField.text ?? ""
    }

}
