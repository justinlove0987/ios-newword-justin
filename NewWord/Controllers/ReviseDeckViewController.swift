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
    
    enum Item: Int {
        static let sections = [newCard, forgetCard, leachCard, masterCard, advanced]
        static let newCard: [Item] = [.learningStpes, .learningGraduatingInterval, .easyInterval]
        static let forgetCard: [Item] = [.relearningSteps, .minumumInterval]
        static let leachCard: [Item] = [.leachThreshold, .leachAction]
        static let masterCard: [Item] = [.masterGraduatingInterval, .consecutiveCorrects]
        static let advanced: [Item] = [.startingEase]
        
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
    
    struct CellProvider: Hashable {
        struct Input {
            let item: Item
            let title: String
            let input: String
        }
        
        struct Selection {
            let item: Item
            let title: String
            let seclection: String
        }
        
        enum CellType {
            case input(Input)
            case selection(Selection)
        }
        
        let id = UUID().uuidString
        let cellType: CellType
        
        static func == (lhs: ReviseDeckViewController.CellProvider, rhs: ReviseDeckViewController.CellProvider) -> Bool {
            return lhs.id == rhs.id
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
        
    }
    
    enum Cell: Hashable {
        struct Input {
            let item: Item
            let title: String
            let input: String
        }
        
        struct Selection {
            let item: Item
            let title: String
            let seclection: String
        }
        
        case input(Input)
        case selection(Selection)
        
        static func == (lhs: ReviseDeckViewController.Cell, rhs: ReviseDeckViewController.Cell) -> Bool {
            return lhs.id == rhs.id
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
        
        var id: String {
            return UUID().uuidString
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    var deck: Deck!
    
    var cellGroup: [[CellProvider]] = []
    
    private var dataSource: UITableViewDiffableDataSource<Int, CellProvider>!
    
    
    
    // MARK: - Lifecycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCellGroup()
        setupDataSource()
    }
    
    // MARK: - Helpers
    
    private func setupCellGroup() {
        let newCard = self.deck.newCard
        
        cellGroup = [
            [CellProvider(cellType: .input(CellProvider.Input(item: .learningStpes, title: "學習階段", input: "\(newCard.learningStpes)"))),
             CellProvider(cellType: .input(CellProvider.Input(item: .learningStpes, title: "學習階段", input: "\(newCard.learningStpes)"))),
             CellProvider(cellType: .input(CellProvider.Input(item: .learningStpes, title: "學習階段", input: "\(newCard.learningStpes)")))
            ]
        ]
    }
    
    private func setupDataSource() {
        dataSource = UITableViewDiffableDataSource(tableView: tableView, cellProvider: { tableView, indexPath, itemIdentifier in
            let factory = DeckSettingCellFactory(tableView: tableView, indexPath: indexPath)
            
            switch itemIdentifier.cellType {
            case .input(let data):
                return factory.createInputCell(title: data.title, input: data.input)
            case .selection(let data):
                return factory.createSelectionCell(title: data.title, selection: data.seclection)
            }
        })
        
        var snapshot = NSDiffableDataSourceSnapshot<Int, CellProvider>()
        var sections = Array(0..<cellGroup.count)
        
        snapshot.appendSections(sections)
        
        for i in 0..<cellGroup.count {
            snapshot.appendItems(cellGroup[i], toSection: i)
        }
        
        dataSource.apply(snapshot)
        tableView.dataSource = dataSource
    }
    
    
    @IBAction func saveAction(_ sender: UIButton) {
        let sections = Section.allCases
        let itemGroups = [Item.newCard, Item.forgetCard, Item.leachCard, Item.masterCard, Item.advanced]
        
        let factory = DeckSettingCellFactory(tableView: tableView)
        
        for i in 0..<itemGroups.count {
            for item in itemGroups[i] {
                
                //                switc
            }
        }
        
        //        let newCard = Deck.NewCard(graduatingInterval: <#T##Int#>, easyInterval: <#T##Int#>, learningStpes: <#T##Double#>)
        //
        //        let lapses = Deck.Lapses(relearningSteps: <#T##Double#>, leachThreshold: <#T##Int#>, minumumInterval: <#T##Int#>)
        //
        //        let advanced = Deck.Advanced(startingEase: <#T##Double#>, easyBonus: <#T##Double#>)
        //
        //        let master = Deck.Master(graduatingInterval: <#T##Int#>, consecutiveCorrects: <#T##Int#>)
        //
        //        Deck(newCard: <#T##Deck.NewCard#>, lapses: <#T##Deck.Lapses#>, advanced: <#T##Deck.Advanced#>, master: <#T##Deck.Master#>, id: deck.id, name: deck.name, cards: [])
        
        self.dismiss(animated: true)
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
