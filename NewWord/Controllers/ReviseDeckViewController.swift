//
//  ReviseDeckViewController.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/5/6.
//

import UIKit

class ReviseDeckViewController: UIViewController {
    
    enum Section: Int, CaseIterable ,Hashable  {
        case newCard
        case forgetCard
        case leachCard
        case masterCard
        case advanced
    }
    
    enum Item {
        static let newCard: [Item] = [.learningStpes, .learningGraduatingInterval, .easyInterval]

        case learningStpes
        case learningGraduatingInterval
        case easyInterval

        case relearningSteps
        case minumumInterval
        case leachThreshold
        case leachAction
        case masterGraduatingInterval
        case consecutiveCorrects
        case startingEase
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    private var dataSource: UITableViewDiffableDataSource<Section, Item>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDataSource()
    }
    
    private func setupDataSource() {
        dataSource = UITableViewDiffableDataSource(tableView: tableView, cellProvider: { tableView, indexPath, itemIdentifier in
            let deck = Deck.createFakeDeck()
            let section = Section.allCases[indexPath.section]
            let factory = DeckSettingCellFactory(tableView: tableView, indexPath: indexPath)

            switch section {
            case .newCard:
                let newCard = deck.newCard

                switch itemIdentifier {
                case .learningStpes:
                    return factory.createInputCell(title: "學習階段", inputText: "\(newCard.learningStpes)")

                case .learningGraduatingInterval:
                    return factory.createInputCell(title: "畢業間隔", inputText: "\(newCard.graduatingInterval)")

                case .easyInterval:
                    return factory.createInputCell(title: "簡單間隔", inputText: "\(newCard.easyInterval)")

                default:
                    break
                }
            default:
                break
            }
            
            return UITableViewCell()
            
        })
        
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections(Section.allCases)
        snapshot.appendItems(Item.newCard, toSection: .newCard)
        
        dataSource.apply(snapshot)
        tableView.dataSource = dataSource
    }
    
}

extension ReviseDeckViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let titles = ["新卡片", "忘記卡片", "低效卡", "高效卡", "進階設定"]

        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 50))
        label.text = titles[section]
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)

        return label
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
}
