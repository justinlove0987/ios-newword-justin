//
//  ViewController.swift
//  NewWord
//
//  Created by justin on 2024/3/29.
//

import UIKit
import CoreData

private let reuseIdentifier = "Cell"

class MainViewController: UIViewController {

    let tableView: UITableView = UITableView()
    var dataSource: [UIViewController] = []

    // MARK: - Lifecycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.frame = view.bounds
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)

        setupViewControllers()
        
        testWritingFile()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    // MARK: - Helpers

    private func setupViewControllers() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let reviewVC = storyboard.instantiateViewController(withIdentifier: "ReviewViewController")
        let exploreVC = ExploreViewController()
        let searchVC = SearchViewController()
        let settingsVC = SettingsViewController()

        dataSource = [reviewVC, exploreVC, searchVC, settingsVC]
    }
    
    private func testWritingFile() {
        // Example usage:
        let newDeck = Deck(newCard: Deck.NewCard(graduatingInterval: 10, easyInterval: 5, learningStpes: 2.0),
                            lapses: Deck.Lapses(relearningSteps: 1.5, leachThreshold: 3, minumumInterval: 2),
                            advanced: Deck.Advanced(startingEase: 2.5, easyBonus: 1.2),
                            master: Deck.Master(graduatingInterval: 100, consecutiveCorrects: 3),
                            id: "new_deck_id",
                            cards: [],
                            name: "New Deck Name")

        JsonManager.writeDeckToFile(deck: newDeck, filename: "decks.json")
    }
}

extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)

        cell.textLabel?.text = String(describing: type(of: dataSource[indexPath.row]))

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        navigationController?.pushViewController(dataSource[indexPath.row], animated: true)
    }
}


