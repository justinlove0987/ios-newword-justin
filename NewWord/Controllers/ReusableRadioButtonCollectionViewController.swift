//
//  ReusableRadioButtonCollectionViewController.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/10/1.
//

import UIKit

class ReusableCollectionViewController<Item: Hashable>: UIViewController , UICollectionViewDelegate {
    
    struct Row: Hashable {
        let item: Item
        let isSelected: Bool
    }
    
    private var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())

    private var dataSource: UICollectionViewDiffableDataSource<Int, Row>!
    private var rows: [Row] = []
    
    var items: [Item] = [] {
        didSet {
            updateData()
            updateSnapshot()
        }
    }
    
    var selectedItem: Item? {
        didSet {
            updateData()
            updateSnapshot()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        updateData()
        setupProperties()
        setupCollectionView()
    }
    
    private func updateData() {
        rows = items.map { item in
            Row(item: item, isSelected: item == selectedItem)
        }
    }
    
    private func setupProperties() {
        self.view.backgroundColor = .background
        self.collectionView.backgroundColor = .background
        
        self.view.addSubview(collectionView)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        
        ])
    }

    private func setupCollectionView() {
        collectionView.register(UINib(nibName: RadioButtonCell.reuseIdentifier, bundle: nil).self, forCellWithReuseIdentifier: RadioButtonCell.reuseIdentifier)
        dataSource = createDataSource()
        collectionView.collectionViewLayout = createCollectionViewLayout()
        collectionView.dataSource = dataSource
        collectionView.delegate = self
        updateSnapshot()
    }

    private func createDataSource() -> UICollectionViewDiffableDataSource<Int, Row> {
        let dataSource = UICollectionViewDiffableDataSource<Int, Row>(
            collectionView: collectionView,
            cellProvider: cellProvider
        )
        
        return dataSource
    }
    
    private func createCollectionViewLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { [weak self] (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            guard let self = self else { return nil }
            
            let item = self.createItem()
            let group = self.createGroup(with: item)
            let section = self.createSection(with: group)
            
            return section
        }
    }
    
    private func updateSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Int, Row>()
        
        let section = 0
        snapshot.appendSections([section])
        snapshot.appendItems(rows, toSection: section)
        
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let row = rows[indexPath.row]
        selectedItem = row.item
        
        updateData()
        updateSnapshot()
    }
    
    func cellProvider(
        collectionView: UICollectionView,
        indexPath: IndexPath,
        itemIdentifier: Row
    ) -> UICollectionViewCell? {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RadioButtonCell.reuseIdentifier, for: indexPath) as! RadioButtonCell
        return cell
    }

}

// MARK: - UICollectionViewCompositionalLayout

extension ReusableCollectionViewController {
    
    private func createItem() -> NSCollectionLayoutItem {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(44)
        )
        return NSCollectionLayoutItem(layoutSize: itemSize)
    }
    
    private func createGroup(with item: NSCollectionLayoutItem) -> NSCollectionLayoutGroup {
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(44)
        )
        return NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize,
            subitems: [item]
        )
    }
    
    private func createSection(with group: NSCollectionLayoutGroup) -> NSCollectionLayoutSection {
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0)
        return section
    }
}

