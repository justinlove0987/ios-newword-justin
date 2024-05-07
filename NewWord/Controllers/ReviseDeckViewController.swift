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
        static let newCard: [Item] = [.learningStpes]
        
        case learningStpes
        case easyInterval
        case learningGraduatingInterval
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
            
//            let lapses = deck.lapses
//            let master = deck.master
//            let advanced = deck.advanced
            
            let section = Section.allCases[indexPath.section]
            
            switch section {
            case .newCard:
                let newCard = deck.newCard
                switch itemIdentifier {
                case .learningStpes:
                    return DeckSettingInputCell.createCell(tableView: tableView, indexPath: indexPath, title: "學習階段", inputText: "\(newCard.learningStpes)")
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
