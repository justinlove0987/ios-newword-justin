//
//  PracticeModeViewController.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/8/27.
//

import UIKit

class PracticeModeViewController: UIViewController, StoryboardGenerated {
    
    static var storyboardName: String = K.Storyboard.main
    
    struct Row: Hashable {
        let practiceType: PracticeMode
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var dataSource: UICollectionViewDiffableDataSource<Int, Row>!
    
    private var rows: [Row] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        setupData()
        setupCollectionView()
    }
    
    private func setupData() {
        for mode in PracticeMode.allCases {
            rows.append(Row(practiceType: mode))
        }
    }

    private func setupCollectionView() {
        collectionView.register(UINib(nibName: RadioButtonCell.reuseIdentifier, bundle: nil).self, forCellWithReuseIdentifier: RadioButtonCell.reuseIdentifier)
        dataSource = createDataSource()
        collectionView.dataSource = dataSource
        collectionView.collectionViewLayout = createCollectionViewLayout()
        collectionView.delegate = self
        updateSnapshot()
    }

    private func createDataSource() -> UICollectionViewDiffableDataSource<Int, Row> {
        // 建立 DataSource
        let dataSource = UICollectionViewDiffableDataSource<Int, Row>(
            collectionView: collectionView,
            cellProvider: cellProvider
        )
        
        return dataSource
    }

    
    private func createCollectionViewLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { [weak self] (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            guard let self = self else { return nil }
            
            // 配置 Item
            let item = self.createItem()
            
            // 配置 Group
            let group = self.createGroup(with: item)
            
            // 配置 Section
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

}

// MARK: - UICollectionViewDelegate

extension PracticeModeViewController: UICollectionViewDelegate {
    
}

// MARK: - UICollectionView DataSource

extension PracticeModeViewController {
    
    // 提供 Cell 的配置方法
    private func cellProvider(
        collectionView: UICollectionView,
        indexPath: IndexPath,
        itemIdentifier: Row
    ) -> UICollectionViewCell? {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RadioButtonCell.reuseIdentifier, for: indexPath) as! RadioButtonCell
        
        cell.titleLabel.text = itemIdentifier.practiceType.title
        
        return cell
    }
}


// MARK: - UICollectionViewCompositionalLayout

extension PracticeModeViewController {
    // 配置 Item
    private func createItem() -> NSCollectionLayoutItem {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(44)
        )
        return NSCollectionLayoutItem(layoutSize: itemSize)
    }
    
    // 配置 Group
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
    
    // 配置 Section
    private func createSection(with group: NSCollectionLayoutGroup) -> NSCollectionLayoutSection {
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0)
        return section
    }
}

