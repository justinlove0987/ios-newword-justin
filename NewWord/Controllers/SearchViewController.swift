//
//  SearchViewController.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/5/3.
//

import UIKit

protocol SearchDataSource: Hashable {
    var title: String { get set }
}


struct SearchClozeDataSource: SearchDataSource {
    var title: String
    var cards: [CDCard]
}

class SearchViewController: UIViewController, StoryboardGenerated {
    
    static var storyboardName: String = "Main"
    
    @IBOutlet weak var searchViewController: UISearchBar!
    
    @IBOutlet weak var tableView: UITableView!
    
    private var filteredCards: [CDCard] = []
    
    private var groupedCards: [SearchClozeDataSource] = []
    
    private var dataSource: UITableViewDiffableDataSource<Int, SearchClozeDataSource>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDataSource()
        setupSearchDataSource()
        updateDataSource()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateDataSource()
    }
    
    private func setupDataSource() {
        dataSource = UITableViewDiffableDataSource(tableView: tableView, cellProvider: { tableView, indexPath, itemIdentifier in
            let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell", for: indexPath) as! SearchCell
            cell.nameLabel.text = itemIdentifier.title
            
            return cell
        })
        
        tableView.dataSource = dataSource

        let decks = CoreDataManager.shared.getDecks()

        filteredCards = decks.flatMap { deck in
            return CoreDataManager.shared.cards(from: deck)
        }
    }
    
    private func setupSearchDataSource() {
        let decks = CoreDataManager.shared.getDecks()
        
        groupedCards = decks.flatMap { deck in
            let cards = CoreDataManager.shared.cards(from: deck)
            
            let groupedCards = groupCardsByText(cards)
            
            return groupedCards
        }
    }
    
    func groupCardsByText(_ cards: [CDCard]) -> [SearchClozeDataSource] {
        var groupedCards = [String: [CDCard]]()

        for card in cards {
            guard let cloze = card.note?.noteType?.cloze,
                  let text = cloze.clozeWord else {
                continue
            }
            
            let key = text
            groupedCards[key, default: []].append(card)
        }

        return groupedCards.map { SearchClozeDataSource(title: $0.key, cards: $0.value) }
    }
    
    private func updateDataSource() {
        var snapshot: NSDiffableDataSourceSnapshot<Int, SearchClozeDataSource> = .init()
        
        snapshot.appendSections([0])
        snapshot.appendItems(groupedCards, toSection: 0)

        dataSource.apply(snapshot)
    }
    
    // MARK: - Actions
    
    @IBAction func deckAction(_ sender: UIButton) {
        let controller = SearchDeckViewController()
        
        controller.callback = { [weak self] decks in
            guard let self = self else { return }

            groupedCards = decks.flatMap { deck in
                let cards = CoreDataManager.shared.cards(from: deck)
                
                let groupedCards = self.groupCardsByText(cards)
                
                return groupedCards
            }
            
            self.updateDataSource()
        }
        
        navigationController?.pushViewController(controller, animated: true)
    }
    
    
    @IBAction func clozeAction(_ sender: UIButton) {
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
        let currentGroupedCards = groupedCards[indexPath.row]
        
        let controller = SearchClozeResultViewController()
        
        controller.cards = currentGroupedCards.cards
        
//        let controller = CardInformationViewController.instantiate()
//        
//        controller.card = filteredCards[indexPath.row]
//        
        navigationController?.pushViewController(controller, animated: true)
        
    }
}
