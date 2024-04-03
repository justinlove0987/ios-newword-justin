//
//  SentenceClozeViewController.swift
//  NewWord
//
//  Created by justin on 2024/3/29.
//

import UIKit

private let reuserIdnetifier = "Cell"

class SentenceClozeViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    var viewModel = SentenceClozeViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(CustomCell.self, forCellReuseIdentifier: reuserIdnetifier)
        viewModel.setup(with: tableView.frame.width)
    }
}

extension SentenceClozeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRowsInSection
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuserIdnetifier, for: indexPath) as! CustomCell
        let words = viewModel.wordsForRows[indexPath.row]

        cell.delegate = self
        cell.configureStackViewSubViews(wtih: words, at: indexPath)
        

        return cell
    }
}

extension SentenceClozeViewController: CustomCellDelegate {
    func answerCorrect() {
        if viewModel.hasNextSentence {
            viewModel.nextSentence()
            tableView.reloadData()
        } else {
            let alert = viewModel.createAlertController()
            present(alert, animated: true)
        }


    }
}

