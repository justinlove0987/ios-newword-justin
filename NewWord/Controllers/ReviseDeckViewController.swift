//
//  ReviseDeckViewController.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/5/6.
//

import UIKit

class ReviseDeckViewController: UIViewController {
    
    enum Section: Int, CaseIterable ,Hashable  {
        enum Item {
            enum NewCard {
                case learningSteps
            }
        }
        
        case newCard
        case forgetCard
        case leachCard
        case masterCard
        case advanced
        
        
    }
    
    enum Item: Int, Hashable {
        static let newCardCases: [Item] = [.learningStpes, .easyInterval, .learningGraduatingInterval]
        
        // New card
        case learningStpes
        case easyInterval
        case learningGraduatingInterval
        
        // Forget card
        case relearningSteps
        case minumumInterval
        
        // Leach card
        case leachThreshold
        case leachAction
        
        // Master card
        case masterGraduatingInterval
        case consecutiveCorrects
        
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    private var dataSource: UITableViewDiffableDataSource<Section, Item>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    private func setupDataSource() {
        dataSource = UITableViewDiffableDataSource(tableView: tableView, cellProvider: { tableView, indexPath, itemIdentifier in
            let section = Section(rawValue: indexPath.section)
            let deck = Deck.createFakeDeck()
            let newCard = deck.newCard
            let lapses = deck.lapses
            let master = deck.master
            let advanced = deck.advanced
            
            switch section {
            case .newCard:
//                switch itemIdentifier {
//                case learningStpes:
//                    let cell = tableView.dequeueReusableCell(withIdentifier: <#T##String#>, for: indexPath) as! DeckSettingInputCell
//                    cell.inputTextField = Deck.
//                    return
//                case easyInterval:
//                    
//                case learningGraduatingInterval:
//                }
                return UITableViewCell()
                
            case .forgetCard:
                return UITableViewCell()
            case .masterCard:
                return UITableViewCell()
            case .leachCard:
                return UITableViewCell()
            case .advanced:
                return UITableViewCell()
            case .none:
                fatalError("Unkown section type")            }
        })
    }

}
