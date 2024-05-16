//
//  ExploreViewController.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/5/3.
//

import UIKit

class ExploreViewController: UIViewController {
    
    @IBOutlet weak var deckLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    private var currentDeck: Deck?
    
    var dataSource: UITableViewDiffableDataSource<Int,Note>!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupDeck()
        setupTableView()
        setupDataSouce()
    }
    
    private func setupDeck() {
        currentDeck = DeckManager.shared.snapshot.first!
        deckLabel.text = currentDeck!.name
    }
    
    private func setupTableView() {
        view.backgroundColor = .orange
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.delegate = self
    }
    
    private func setupDataSouce() {
        dataSource = UITableViewDiffableDataSource(tableView: tableView, cellProvider: { tableView, indexPath, itemIdentifier in
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            
            var config = cell.defaultContentConfiguration()
            
            switch itemIdentifier.noteType {
            case .sentenceCloze(let data):
                config.text = data.clozeWord.text
                break
            }
            
            cell.contentConfiguration = config
            
            return cell
        })
        
        
        var snapshot = NSDiffableDataSourceSnapshot<Int, Note>()
        NoteManager.shared.addFakeNotes()
        
        let notes = NoteManager.shared.notes
        
        snapshot.appendSections([0])
        snapshot.appendItems(notes, toSection: 0)
        
        tableView.dataSource = dataSource
        dataSource.apply(snapshot)
    }
    
    private func readFileFromLocal() -> [Note] {
        let path = Bundle.main.path(forResource: "notes", ofType: "json")!
        let jsonData = try! Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
        
        let result = (try? JSONDecoder().decode([Note].self, from: jsonData)) ?? []
        
        return result
    }

}

extension ExploreViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard var currentDeck = currentDeck else { return }
        
        var snapshot = dataSource.snapshot()
        
        let note = dataSource.itemIdentifier(for: indexPath)!
        snapshot.deleteItems([note])
        
        dataSource.apply(snapshot, animatingDifferences: true)
        
        let card = Card(id: UUID().uuidString, 
                        note: note,
                        learningRecords: [])
        
        currentDeck.cards.append(card)
        
        var decks = DeckManager.shared.snapshot
        
        for i in 0..<decks.count {
            if decks[i].id == currentDeck.id {
                decks.remove(at: i)
                decks.insert(currentDeck, at: i)
                break
            }
        }
        
        DeckManager.shared.snapshot = decks
        DeckManager.shared.writeToFile()
        
        let deck = DeckManager.shared.snapshot.first!
        print(deck)
    }
}
