//
//  ReviewViewController.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/5/3.
//

import UIKit

class ReviewViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    var dataSource: UITableViewDiffableDataSource<Int, Deck>!
    var viewControllers: [UIViewController] = []

    var decks: [Deck] = []

    // MARK: - Lifecycles

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    
    func setup() {
        setupViewControllers()
        setupDecks()
        setupDataSource()
    }

    private func setupViewControllers() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: String(describing: SentenceClozeViewController.self))
        viewControllers = [vc]
    }

    private func setupDecks() {
        decks.append(Deck.createFakeDeck())
    }

    private func setupDataSource() {
        dataSource = UITableViewDiffableDataSource(tableView: tableView, cellProvider: { tableView, indexPath, itemIdentifier in
            let cell = tableView.dequeueReusableCell(withIdentifier: DeckCell.reuseIdentifier, for: indexPath) as! DeckCell
            
            
            cell.deck = itemIdentifier
            cell.nameLabel.text = itemIdentifier.name
            cell.settingAction = {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: String(describing: ReviseDeckViewController.self)) as! ReviseDeckViewController
                vc.deck = self.decks[indexPath.row]
                
                self.present(vc, animated: true)
            }
            return cell
        })

        var snapshot = NSDiffableDataSourceSnapshot<Int, Deck>()
        snapshot.appendSections([1])
        snapshot.appendItems(decks, toSection: 1)

        tableView.dataSource = dataSource
        dataSource.apply(snapshot)
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
                var deck = Deck.createFakeDeck()
                deck.name = text

                var snapshot = self.dataSource.snapshot()
                snapshot.appendItems([deck], toSection: 1)
                self.dataSource.apply(snapshot)
            }
        }

        alert.addAction(confirm)
        alert.addAction(cancel)

        present(alert, animated: true)
    }

}

extension ReviewViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        navigationController?.pushViewController(viewControllers[0], animated: true)
    }
}
