//
//  ReviewViewController.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/5/3.
//

import UIKit

class ReviewViewController: UIViewController, StoryboardGenerated {

    static var storyboardName: String = "Main"

    enum SectionIdentifier: Int, CaseIterable, Hashable {
        case first
        case second
    }

    enum ItemIdentifer: Hashable {
        case allPractices
        case practiceByDeck(CDDeck)
    }

    // MARK: - Properties

    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!

    var dataSource: UICollectionViewDiffableDataSource<SectionIdentifier, ItemIdentifer>!

    var sections: [SectionIdentifier: [ItemIdentifer]] = [:]

    private var decks: [CDDeck] = []

    // MARK: - Lifecycles

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateData()
        updateSnapshot()
    }

    // MARK: - Helpers

    private func setup() {
        updateData()
        setupCollectionView()
        setupProperties()
        updateSnapshot()
        // setupNotifications()
    }

    private func updateData() {
        let decks = CoreDataManager.shared.getAll(ofType: CDDeck.self)

        let filteredDecks = decks.filter { deck in
            return deck.isUserGenerated || deck.isSystemGeneratedWithPractice
        }

        let deckItems = filteredDecks.map { ItemIdentifer.practiceByDeck($0) }

        sections = [
            .first: [.allPractices],
            .second: deckItems
        ]
    }

    private func setupCollectionView() {
        collectionView.register(UINib(nibName: DeckPracticeCell.reuseIdentifier, bundle: nil), forCellWithReuseIdentifier: DeckPracticeCell.reuseIdentifier)
        collectionView.register(UINib(nibName: SingleDeckPracticeCell.reuseIdentifier, bundle: nil), forCellWithReuseIdentifier: SingleDeckPracticeCell.reuseIdentifier)
        dataSource = createDataSource()
        collectionView.dataSource = dataSource
        collectionView.collectionViewLayout = createCollectionViewLayout()
        collectionView.delegate = self
    }

    private func createDataSource() -> UICollectionViewDiffableDataSource<SectionIdentifier, ItemIdentifer> {
        let dataSource = UICollectionViewDiffableDataSource<SectionIdentifier, ItemIdentifer>(
            collectionView: collectionView,
            cellProvider: cellProvider
        )

        return dataSource
    }

    func cellProvider(
        collectionView: UICollectionView,
        indexPath: IndexPath,
        itemIdentifier: ItemIdentifer
    ) -> UICollectionViewCell? {

        switch itemIdentifier {

        case .allPractices:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DeckPracticeCell.reuseIdentifier, for: indexPath) as! DeckPracticeCell
            cell.configureUI(with: itemIdentifier)
            return cell

        case .practiceByDeck(_):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SingleDeckPracticeCell.reuseIdentifier, for: indexPath) as! SingleDeckPracticeCell
            cell.configureUI(with: itemIdentifier)
            return cell
        }
    }

    private func createCollectionViewLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { [weak self] (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            guard let self = self else { return nil }

            let sectionIdentifier = ReviewViewController.SectionIdentifier.allCases[sectionIndex]

            let item = self.createItem(for: sectionIdentifier)
            let group = self.createGroup(for: sectionIdentifier, with: item)
            let section = self.createSection(for: sectionIdentifier, with: group)

            return section
        }
    }

    private func setupProperties() {
        addButton.addDefaultBorder(cornerRadius: 10)
    }

    private func updateSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<SectionIdentifier, ItemIdentifer>()

        let sortedSections = sections.keys.sorted(by: { $0.rawValue < $1.rawValue })

        for section in sortedSections {
            snapshot.appendSections([section])

            if let item = sections[section] {
                snapshot.appendItems(item, toSection: section)
            }

        }

        dataSource.apply(snapshot)
    }

    // MARK: - Actions

//    @IBAction func addDeckAction(_ sender: UIButton) {
//        let alert = UIAlertController(title: "新增空白牌組", message: nil, preferredStyle: .alert)
//
//        alert.addTextField { (textField) in
//            textField.placeholder = "牌組名稱"
//        }
//
//        let cancel = UIAlertAction(title: "取消", style: .cancel)
//        let confirm = UIAlertAction(title: "新增", style: .default) { action in
//            if let textField = alert.textFields?.first, let text = textField.text {
//                let deck = CoreDataManager.shared.addDeck(name: text)
//                deck.name = text
//
//                var snapshot = self.dataSource.snapshot()
//                snapshot.appendItems([deck], toSection: 0)
//                self.dataSource.apply(snapshot)
//            }
//        }
//
//        alert.addAction(confirm)
//        alert.addAction(cancel)
//        present(alert, animated: true)
//    }

    private func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleDeckUpdate(notification:)), name: .deckDidUpdate, object: nil)
    }

    @IBAction func addClozeAction(_ sender: UIButton) {
        let controller = ReviseContextViewController.instantiate()
        
        controller.modalTransitionStyle = .crossDissolve
        controller.modalPresentationStyle = .fullScreen
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func handleDeckUpdate(notification: Notification) {
       updateSnapshot()
    }
    
}

// MARK: - UICollectionViewDelegate

extension ReviewViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let section = SectionIdentifier.allCases[indexPath.section]

        if let items = sections[section] {
            let item = items[indexPath.item]

            switch item {
            case .allPractices:
                break
                
            case .practiceByDeck(let deck):
                let controller = ShowCardsViewController.instantiate()
                controller.deck = deck
                controller.modalTransitionStyle = .crossDissolve
                controller.modalPresentationStyle = .fullScreen
                controller.hidesBottomBarWhenPushed = true
                controller.view.layoutIfNeeded()

                navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
}

// MARK: - UICollectionViewCompositionalLayout

extension ReviewViewController {

    private func createItem(for section: SectionIdentifier) -> NSCollectionLayoutItem {

        let itemSize: NSCollectionLayoutSize

        switch section {
        case .first:
            itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(0.5),
                heightDimension: .fractionalHeight(1.0)
            )

        case .second:
            itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(100)
            )
        }

        return NSCollectionLayoutItem(layoutSize: itemSize)
    }

    private func createGroup(for section: SectionIdentifier, with item: NSCollectionLayoutItem) -> NSCollectionLayoutGroup {

        let groupSize: NSCollectionLayoutSize

        switch section {
        case .first:
            groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalWidth(0.5)
            )

            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize,
                subitems: [item]
            )

            group.interItemSpacing = .flexible(15)

            return group

        case .second:
            groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(100)
            )

            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: groupSize,
                subitems: [item]
            )

            return group
        }
    }

    private func createSection(for section: SectionIdentifier, with group: NSCollectionLayoutGroup) -> NSCollectionLayoutSection {
        let layoutSection = NSCollectionLayoutSection(group: group)

        // 設置邊界的內邊距
        layoutSection.contentInsets = NSDirectionalEdgeInsets(top: 15, leading: 15, bottom: 15, trailing: 15)

        layoutSection.interGroupSpacing = 15

        return layoutSection
    }
}

