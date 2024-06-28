//
//  SearchClozeResultViewController.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/6/28.
//

import UIKit

class SearchClozeResultViewController: UIViewController {
    
    var cards: [CDCard] = []
    
    private let tableView: UITableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        view.addSubview(tableView)
        
        tableView.frame = view.bounds
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: SearchClozeResultCell.reuseIdentifier, bundle: nil), forCellReuseIdentifier: SearchClozeResultCell.reuseIdentifier)
    }

}

extension SearchClozeResultViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cards.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currentCard = cards[indexPath.row]
        guard let cloze = currentCard.note?.noteType?.cloze else { fatalError() }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchClozeResultCell.reuseIdentifier, for: indexPath) as! SearchClozeResultCell
        
        cell.updateUI(cloze)
        
        return cell
        
    }
}
