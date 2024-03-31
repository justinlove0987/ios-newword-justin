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

    var numberOfRowsInSection: [[Word]] = []
    var article: Articles = .init(words: [])

    override func viewDidLoad() {
        super.viewDidLoad()

        setupArticle()
        numberOfRowsInSection = countWordsInRows()

        tableView.register(CustomCell.self, forCellReuseIdentifier: reuserIdnetifier)
    }

    func countWordsInRows() -> [[Word]] {
        var wordsInRows: [[Word]] = []
        var items: [Word] = []
        var currentBounds: CGFloat = 0

        for i in 0..<article.words.count {
            let word = article.words[i]

            if (currentBounds + word.bound.width) >= tableView.frame.width {
                wordsInRows.append(items)
                currentBounds = 0
                items = []
            }

            currentBounds += word.bound.width
            currentBounds += 10
            items.append(article.words[i])
        }

        wordsInRows.append(items)

        return wordsInRows
    }

    func setupArticle() {
        let word = ["Life", "is", "like", "riding", "a", "bicycle", ".", "To", "keep", "your", "balance", ",", "you", "must", "keep", "moving", "."]


        let wordViews = word.map { word in
            let wordModel: Word;

            if word == "balance" {
                wordModel = Word(text: word, isReview: true)
            } else {
                wordModel = Word(text: word, isReview: false)
            }

            return wordModel
        }

        article = Articles(words: wordViews)
    }
}

extension SentenceClozeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRowsInSection.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuserIdnetifier, for: indexPath) as! CustomCell

        cell.configureStackViewSubViews(wtih: numberOfRowsInSection[indexPath.row], at: indexPath)
        

        return cell
    }
}

