//
//  SearchDeckViewController.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/6/27.
//

import UIKit

class SearchDeckViewController: UIViewController {
    
    struct Row {
        var isSelected = false
        var deck: CDDeck
    }
    
    private let tableView: UITableView = UITableView()
    
    private var decks: [CDDeck]?
    
    var callback: (([CDDeck]) ->())?
    
    private var rows: [Row] = []
    
    private var selectedIndices = Set<Int>()

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        let decks = CoreDataManager.shared.getDecks()
        
        for i in 0..<decks.count {
            let deck = decks[i]
            
            guard let id = deck.id else { return }
            
            let isSelected = CoreDataManager.shared.isSelected(from: id, type: .deck)
            let row = Row(isSelected: isSelected, deck: deck)
            
            if isSelected {
                selectedIndices.insert(i)
            }
            
            rows.append(row)
        }

        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: SearchSelectionCell.reuseIdentifier, bundle: nil), forCellReuseIdentifier: SearchSelectionCell.reuseIdentifier)
        tableView.frame = view.bounds

        let rightBarButtonItem = UIBarButtonItem(title: "完成", style: .done, target: self, action: #selector(completeAction))
        
        navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    
    @objc func completeAction(_ sender: UIBarButtonItem) {
        guard let callback else { return }

        var filteredDecks: [CDDeck] = []

        for i in 0..<rows.count {
            let row = rows[i]

            guard let id = row.deck.id else { continue }

            if row.isSelected {
                filteredDecks.append(row.deck)
            }

            CoreDataManager.shared.updateSelected(from: id, type: .deck, isSelected: row.isSelected)
        }

        callback(filteredDecks)
        
        navigationController?.popViewController(animated: true)
    }
}

extension SearchDeckViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchSelectionCell.reuseIdentifier, for: indexPath) as! SearchSelectionCell
        cell.selectionStyle = .none

        let row = rows[indexPath.row]
        
        cell.isSelected = row.isSelected
        cell.updateUI(deck: row.deck)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if rows[indexPath.row].isSelected {
            tableView.deselectRow(at: IndexPath(row: indexPath.row, section: 0), animated: true)
        } else {
            tableView.selectRow(at: IndexPath(row: indexPath.row, section: 0), animated: true, scrollPosition: .none)
        }
        
        rows[indexPath.row].isSelected.toggle()

        for i in 0..<rows.count {
            let row = rows[i]
            let cell = tableView.cellForRow(at: IndexPath(row: i, section: 0)) as! SearchSelectionCell
            cell.isSelected = row.isSelected
            
        }
    }
}
