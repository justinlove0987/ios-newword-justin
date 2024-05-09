//
//  ReviseDeckViewController.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/5/6.
//

import UIKit

class ReviseDeckViewController: UIViewController {

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

    var cellProviderGroup: [[CellProvider]] = []

    private var dataSource: UITableViewDiffableDataSource<Int, CellProvider>!



    // MARK: - Lifecycles

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCellProviderGroup()
        setupDataSource()
    }

    // MARK: - Helpers

    private func setupCellProviderGroup() {
        let newCard = self.deck.newCard
        let lapses = self.deck.lapses
        let master = self.deck.master
        let advanced = self.deck.advanced

        cellProviderGroup = [
            [
                CellProvider(cellType: .input(CellProvider.Input(item: .learningStpes, title: "學習階段", input: "\(newCard.learningStpes)"))),
                CellProvider(cellType: .input(CellProvider.Input(item: .learningGraduatingInterval, title: "畢業間隔", input: "\(newCard.graduatingInterval)"))),
                CellProvider(cellType: .input(CellProvider.Input(item: .easyInterval, title: "簡單間隔", input: "\(newCard.easyInterval)")))
            ],
            [
                CellProvider(cellType: .input(CellProvider.Input(item: .relearningSteps, title: "重新學習階段", input: "\(lapses.relearningSteps)"))),
                CellProvider(cellType: .input(CellProvider.Input(item: .minumumInterval, title: "最短間隔", input: "\(lapses.minumumInterval)")))
            ],
            [
                CellProvider(cellType: .input(CellProvider.Input(item: .leachThreshold, title: "忘記次數", input: "\(lapses.leachThreshold)"))),
                CellProvider(cellType: .selection(CellProvider.Selection(item: .leachAction, title: "低效卡動作", seclection: "")))
            ],
            [
                CellProvider(cellType: .input(CellProvider.Input(item: .masterGraduatingInterval, title: "間隔超過天數", input: "\(master.graduatingInterval)"))),
                CellProvider(cellType: .input(CellProvider.Input(item: .consecutiveCorrects, title: "最短間隔", input: "\(master.consecutiveCorrects)")))

            ],
            [
                CellProvider(cellType: .input(CellProvider.Input(item: .startingEase, title: "起始輕鬆度", input: "\(advanced.startingEase)"))),
            ],
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
        let sections = Array(0..<cellProviderGroup.count)

        snapshot.appendSections(sections)

        for i in 0..<cellProviderGroup.count {
            snapshot.appendItems(cellProviderGroup[i], toSection: i)
        }

        dataSource.apply(snapshot)
        tableView.dataSource = dataSource
    }


    @IBAction func saveAction(_ sender: UIButton) {
        guard var deck = self.deck else { return }

        for i in 0..<cellProviderGroup.count {
            for j in 0..<cellProviderGroup[i].count {

                let itemIdentifier = cellProviderGroup[i][j]

                if let cell = dataSource?.tableView(tableView, cellForRowAt: IndexPath(row: j, section: i)) {
                    if let inputCell = cell as? DeckSettingInputCell {
                        let input = inputCell.inputTextField.text!

                        switch itemIdentifier.cellType {
                        case .input(let inputData):
                            switch inputData.item {

                            case .learningStpes:
                                deck.newCard.learningStpes = Double(input)!
                            case .learningGraduatingInterval:
                                deck.newCard.graduatingInterval = Int(input)!

                            case .easyInterval:
                                deck.newCard.easyInterval = Int(input)!

                            case .relearningSteps:
                                deck.lapses.relearningSteps = Double(input)!
                            case .minumumInterval:
                                deck.lapses.minumumInterval = Int(input)!

                            case .leachThreshold:
                                deck.lapses.leachThreshold = Int(input)!

                            case .masterGraduatingInterval:
                                deck.master.graduatingInterval = Int(input)!
                            case .consecutiveCorrects:
                                deck.master.consecutiveCorrects = Int(input)!

                            case .startingEase:
                                deck.advanced.startingEase = Double(input)!

                            default:
                                break
                            }

                        default: break
                        }
                    }

                    if let _ = cell as? DeckSettingSelectionCell {
                        switch itemIdentifier.cellType {
                        case .selection(let data):
                            switch data.item {
                            case .leachAction:
                                break
                            default:
                                break
                            }
                        default: break
                        }


                    }
                }

            }
        }

        print(deck.newCard.graduatingInterval)
        print(deck.advanced.startingEase)

        self.dismiss(animated: true)
    }

    private func updateDataSource() {

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
