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
    
    private var currentDeck: CDDeck?

    var dataSource: UITableViewDiffableDataSource<Int,CDNote>!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupDeck()
        setupTableView()
        setupDataSouce()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        var notes = CoreDataManager.shared.createFakeCloze()
        let bNotes = CoreDataManager.shared.creaetFakeSentenceCloze()
        notes += bNotes

        var snapshot = dataSource.snapshot()

        snapshot.appendItems(notes, toSection: 0)

        dataSource.apply(snapshot)

        tableView.reloadData()
    }

    private func setupDeck() {
        currentDeck = CoreDataManager.shared.getDecks().first!
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
            
            switch itemIdentifier.noteType!.content {
            case .sentenceCloze(let data):
                config.text = data.clozeWord?.text
                break
            case .prononciation:
                break
            case .cloze:
                guard let cloze = itemIdentifier.noteType?.cloze else { fatalError() }
                config.text = cloze.id
            default:
                break
            }
            
            cell.contentConfiguration = config
            
            return cell
        })
        
        
        var snapshot = NSDiffableDataSourceSnapshot<Int, CDNote>()
        NoteManager.shared.addFakeNotes()
        

        let notes = CoreDataManager.shared.createFakeCloze()

        snapshot.appendSections([0])
        snapshot.appendItems(notes, toSection: 0)
        
        tableView.dataSource = dataSource
        dataSource.apply(snapshot)
    }

}

extension ExploreViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let currentDeck = currentDeck else { return }
        
        var snapshot = dataSource.snapshot()
        
        let note = dataSource.itemIdentifier(for: indexPath)!

        snapshot.deleteItems([note])
        dataSource.apply(snapshot, animatingDifferences: true)

        CoreDataManager.shared.addCard(to: currentDeck, with: note)
    }
}
