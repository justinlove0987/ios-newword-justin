//
//  SearchViewController.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/5/3.
//

import UIKit

class SearchViewController: UIViewController, StoryboardGenerated {
    
    static var storyboardName: String = "Main"
    
    @IBOutlet weak var searchViewController: UISearchBar!
    
    @IBOutlet weak var tableView: UITableView!
    
    private var cards: [CDCard] = []
    
    private var filteredCards: [CDCard] = []
    
    private var dataSource: UITableViewDiffableDataSource<Int, CDCard>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDataSource()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateDataSource()
    }
    
    private func setupDataSource() {
        dataSource = UITableViewDiffableDataSource(tableView: tableView, cellProvider: { tableView, indexPath, itemIdentifier in
            let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell", for: indexPath) as! SearchCell
            cell.nameLabel.text = itemIdentifier.id
            
            return cell
        })
        
        tableView.dataSource = dataSource
    }
    
    private func updateDataSource() {
        cards = CoreDataManager.shared.getCards()
        
        var snapshot: NSDiffableDataSourceSnapshot<Int, CDCard> = .init()
        
        snapshot.appendSections([0])
        snapshot.appendItems(cards, toSection: 0)
        
        dataSource.apply(snapshot)
    }

}

extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
    }

}
