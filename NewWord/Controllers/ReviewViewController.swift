//
//  ReviewViewController.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/5/3.
//

import UIKit

private let reuseIdentifier = "Cell"

class ReviewViewController: UIViewController {
    
    let tableView: UITableView = UITableView()
    var dataSource: [UIViewController] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
        
        tableView.frame = view.bounds
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)

        setup()
    }
    
    
    func setup() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: String(describing: SentenceClozeViewController.self))
        
        dataSource = [vc]
    }

}

extension ReviewViewController: UITableViewDataSource, UITableViewDelegate {
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
