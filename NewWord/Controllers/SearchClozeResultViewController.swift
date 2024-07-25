//
//  SearchClozeResultViewController.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/6/28.
//

import UIKit

class SearchClozeResultViewController: UIViewController, StoryboardGenerated {

    static var storyboardName: String = K.Storyboard.main

    var cards: [CDCard] = []
    
    private let tableView: UITableView = UITableView(frame: .zero, style: .plain)

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        navigationController?.navigationBar.tintColor = UIColor.label

        view.addSubview(tableView)
        view.backgroundColor = UIColor.background

        tableView.frame = view.bounds
        tableView.backgroundColor = UIColor.background

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

        guard let cloze = CoreDataManager.shared.getCloze(from: currentCard) else { fatalError() }

        let cell = tableView.dequeueReusableCell(withIdentifier: SearchClozeResultCell.reuseIdentifier, for: indexPath) as! SearchClozeResultCell
        
        cell.updateUI(cloze)
        
        return cell
        
    }
}
