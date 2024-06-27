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
        let decks = CoreDataManager.shared.getDecks()
        
        filteredCards = decks.flatMap { deck in
            return CoreDataManager.shared.cards(from: deck)
        }
        
        var snapshot: NSDiffableDataSourceSnapshot<Int, CDCard> = .init()
        
        snapshot.appendSections([0])
        snapshot.appendItems(filteredCards, toSection: 0)
        
        dataSource.apply(snapshot)
    }
    
    
    @IBAction func deckAction(_ sender: UIButton) {
        let controller = SearchDeckViewController()
        
        controller.callback = { [weak self] decks in
            self?.filteredCards = decks.flatMap { deck in
                return CoreDataManager.shared.cards(from: deck)
            }
        }
        
        navigationController?.pushViewController(controller, animated: true)
    }
}

// MARK: - UISearchBarDelegate

extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
    }
}

// MARK: - UITableViewDelegate

extension SearchViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let controller = CardInformationViewController.instantiate()
        
        controller.card = filteredCards[indexPath.row]
        
        navigationController?.pushViewController(controller, animated: true)
        
    }
}
