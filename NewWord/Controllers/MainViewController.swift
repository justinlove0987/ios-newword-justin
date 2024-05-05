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

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.frame = view.bounds
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)

        setupViewControllers()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }

    private func setupViewControllers() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let reviewVC = storyboard.instantiateViewController(withIdentifier: "ReviewViewController")
        let exploreVC = ExploreViewController()
        let searchVC = SearchViewController()
        let settingsVC = SettingsViewController()

        dataSource = [reviewVC, exploreVC, searchVC, settingsVC]
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




//struct Vocabulary1 {
//    let state: VocabularyState1
//}
//
//class VocabularyState1 {
//    var completedDate: Date = Date()
//    var id: String = UUID().uuidString
//    var type: VocabularyState1.type = .review
//
//    enum type {
//        case test(VacabularyTest)
//        case review
//        case preview
//        case storage
//    }
//
//}
//
//class VacabularyTest {
//    var firdtTestDate: Date = Date()
//    var type: VacabularyTest.type = .sentenceCloze(SentenceCloze(cloze: ""))
//
//    enum type {
//        case sentenceCloze(SentenceCloze)
//        case vocabularCloze
//    }
//}


