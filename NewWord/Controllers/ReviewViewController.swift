//
//  ReviewViewController.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/5/3.
//

import UIKit

class ReviewViewController: UIViewController {

    // MARK: - Properties
    
    @IBOutlet weak var tableView: UITableView!

    var dataSource: UITableViewDiffableDataSource<Int, Deck>!

    // MARK: - Lifecycles

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let decks = DeckManager.shared.snapshot
        decks.forEach { print("stored id counts \($0.storedCardIds.count)") }
        
        updateDataSource()
    }

    // MARK: - Helpers

    private func setup() {
        setupDataSource()
        setupNotifications()
    }

    private func setupDataSource() {
        dataSource = UITableViewDiffableDataSource(tableView: tableView, cellProvider: { tableView, indexPath, itemIdentifier in
            let cell = tableView.dequeueReusableCell(withIdentifier: DeckCell.reuseIdentifier, for: indexPath) as! DeckCell

            cell.deck = itemIdentifier
            cell.nameLabel.text = itemIdentifier.name

            cell.settingAction = {
                let vc = ReviseDeckViewController.instantiate()
                
                vc.deck = itemIdentifier
                
                self.navigationController?.pushViewController(vc, animated: true)
            }
            return cell
        })
        
        tableView.dataSource = dataSource
        updateDataSource()
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleDeckUpdate(notification:)), name: .deckDidUpdate, object: nil)

    }

    private func updateDataSource() {
        let decks = DeckManager.shared.snapshot
        
        decks.forEach { print($0.name) }

        var snapshot = NSDiffableDataSourceSnapshot<Int, Deck>()
        snapshot.appendSections([0])
        snapshot.appendItems(decks, toSection: 0)

        dataSource.apply(snapshot)
        tableView.reloadData()
    }

    // MARK: - Actions

    @IBAction func addDeckAction(_ sender: UIButton) {
        let alert = UIAlertController(title: "新增空白牌組", message: nil, preferredStyle: .alert)

        alert.addTextField { (textField) in
            textField.placeholder = "牌組名稱"
        }

        let cancel = UIAlertAction(title: "取消", style: .cancel)
        let confirm = UIAlertAction(title: "新增", style: .default) { action in
            if let textField = alert.textFields?.first, let text = textField.text {
                var deck = DeckManager.shared.createDefaultDeck()
                deck.name = text
                
                DeckManager.shared.add(deck)
                DeckManager.shared.writeToFile()

                var snapshot = self.dataSource.snapshot()
                snapshot.appendItems([deck], toSection: 0)
                self.dataSource.apply(snapshot)
            }
        }

        alert.addAction(confirm)
        alert.addAction(cancel)
        present(alert, animated: true)
    }
    
    @objc func handleDeckUpdate(notification: Notification) {
        updateDataSource()
    }
}

// MARK: - UITableViewDelegate

extension ReviewViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let deck = dataSource.itemIdentifier(for: indexPath) else { return }

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let vc = storyboard.instantiateViewController(identifier: String(describing: ShowCardsViewController.self)) { coder in
            
            let vc = ShowCardsViewController(coder: coder, deck: deck)
            
            return vc
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - ReviseDeckViewControllerDelegate

extension ReviewViewController: RevisePresetViewControllerDelegate {
    func didTapSaveButton(_ controller: RevisePresetViewController, revisedDeck: Deck) {
        
    }
}
