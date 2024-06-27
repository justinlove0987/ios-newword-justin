//
//  SearchDeckViewController.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/6/27.
//

import UIKit

class SearchDeckViewController: UIViewController {
    
    private let tableView: UITableView = UITableView()
    
    private var decks: [CDDeck]?
    
    var callback: (([CDDeck]) ->())?
    
    private var selectedIndices = Set<Int>()

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        decks = CoreDataManager.shared.getDecks()
        
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: SearchSelectionCell.reuseIdentifier, bundle: nil), forCellReuseIdentifier: SearchSelectionCell.reuseIdentifier)
        tableView.frame = view.bounds
        tableView.allowsMultipleSelection = true
        
        let rightBarButtonItem = UIBarButtonItem(title: "完成", style: .done, target: self, action: #selector(completeAction))
        
        navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    
    @objc func completeAction(_ sender: UIBarButtonItem) {
        guard let decks else { return }
        guard let callback else { return }
        
        callback(decks)
        
        navigationController?.popViewController(animated: true)
    }
}

extension SearchDeckViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let decks else { return 0 }
        
        return decks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let decks else { return UITableViewCell() }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchSelectionCell.reuseIdentifier, for: indexPath) as! SearchSelectionCell
        
        let currentDeck = decks[indexPath.row]
        
//        cell.isSelected = indexPath.row == 0
        
        cell.updateUI(deck: currentDeck)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let decks else { return }
        
        let currentSelectedRow = indexPath.row
        
        if selectedIndices.contains(currentSelectedRow) {
            selectedIndices.remove(currentSelectedRow)
        } else {
            selectedIndices.insert(currentSelectedRow)
        }
        
        for i in 0..<decks.count {
            let cell = tableView.cellForRow(at: IndexPath(row: i, section: 0)) as! SearchSelectionCell
            cell.isSelected = selectedIndices.contains(i)
        }
    }
}
