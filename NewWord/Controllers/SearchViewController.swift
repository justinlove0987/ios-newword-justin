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
    var contexts: [CDPracticeContext]
}

class SearchViewController: UIViewController, StoryboardGenerated {

    typealias GroupedCards = [SearchClozeDataSource]

    static var storyboardName: String = "Main"
    
    @IBOutlet weak var searchViewController: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var deckFilterButton: UIButton!

    private var dataSource: UITableViewDiffableDataSource<Int, SearchClozeDataSource>!

    private var groupedCards: GroupedCards = []

    private var searchText: String? = nil {
        didSet {
            filterDataSource()
            updateDataSource()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupTableViewDataSource()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        filterDataSource()
        updateDataSource()
    }

    private func setup() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tap))
        self.view.addGestureRecognizer(tap)

        tableView.register(UINib(nibName: SearchCell.reuseIdentifier, bundle: nil), forCellReuseIdentifier: SearchCell.reuseIdentifier)

        deckFilterButton.addDefaultBorder(cornerRadius: 8)
    }

    private func setupTableViewDataSource() {
        dataSource = UITableViewDiffableDataSource(tableView: tableView, cellProvider: { tableView, indexPath, itemIdentifier in
            let cell = tableView.dequeueReusableCell(withIdentifier: SearchCell.reuseIdentifier, for: indexPath) as! SearchCell
            cell.nameLabel.text = itemIdentifier.title

            return cell
        })
        
        tableView.dataSource = dataSource
    }

    private func filterSearchText(_ searhcText: String? ,to groupedCards: GroupedCards) -> GroupedCards {
        var groupedCards = groupedCards

        if let searchText, !searchText.isEmpty {
            groupedCards = groupedCards.filter { groupedCards in
                let searchText = searchText.lowercased()
                return groupedCards.title.contains(searchText)
            }
        }

        return groupedCards
    }

    private func filterSelectedDecks(_ decks: [CDDeck]) -> [CDDeck] {
        let decks = decks.filter { deck in
            guard let id = deck.id else { return false }
            return CoreDataManager.shared.isSelected(from: id, type: .deck)
        }

        return decks
    }

    private func filterDataSource() {
         let contexts = CoreDataManager.shared.getAll(ofType: CDPracticeContext.self)
        
        let groupedCards = contexts.map { practiceContext in
            let title = practiceContext.context ?? "title"
            
            return SearchClozeDataSource(title: title, contexts: [practiceContext])
        }
        
        self.groupedCards = groupedCards
    }

    private func updateDataSource() {
        var snapshot: NSDiffableDataSourceSnapshot<Int, SearchClozeDataSource> = .init()
        
        snapshot.appendSections([0])
        snapshot.appendItems(groupedCards, toSection: 0)

        dataSource.apply(snapshot)
    }

    @objc func tap(_ sender: UITapGestureRecognizer) {
        searchViewController.resignFirstResponder()
        
        let location = sender.location(in: tableView)

        if let indexPath = tableView.indexPathForRow(at: location) {
            tableView(tableView, didSelectRowAt: indexPath)
        }
    }

    // MARK: - Actions
    
    @IBAction func deckAction(_ sender: UIButton) {
        let controller = SearchDeckViewController()
        
        controller.callback = { [weak self] decks in
            guard let self = self else { return }

            self.filterDataSource()
            self.updateDataSource()
        }
        
        navigationController?.pushViewController(controller, animated: true)
    }
}

// MARK: - UISearchBarDelegate

extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
    }
}

// MARK: - UITableViewDelegate

extension SearchViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentGroupedCards = groupedCards[indexPath.row]
        
        let controller = SearchClozeResultViewController.instantiate()
//        controller.cards = currentGroupedCards.cards

        navigationController?.pushViewController(controller, animated: true)
        
    }
}

extension SearchViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == tableView {
            searchViewController.resignFirstResponder()
        }
    }
}
