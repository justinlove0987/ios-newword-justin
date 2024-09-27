//
//  PracticeModeViewController.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/9/27.
//

import UIKit


class PracticeModeViewController: UIViewController, StoryboardGenerated {
    
    static var storyboardName: String = K.Storyboard.main
    
    struct Row: Hashable {
        let practiceType: PracticeType
        let isSelected: Bool
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var dataSource: UICollectionViewDiffableDataSource<Int, Row>!
    
    private var rows: [Row] = []
    
    var practice: CDPractice?

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        updateData()
        setupCollectionView()
    }
    
    private func updateData() {
        rows = []
        
        guard let practiceType = practice?.type else { return }
        
        for currentPracticeType in PracticeType.allCases {
            let isSelected = currentPracticeType.rawValue == practiceType.rawValue
            
            rows.append(Row(practiceType: currentPracticeType, isSelected: isSelected))
        }
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
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let row = rows[indexPath.row]
        
        practice?.typeRawValue = row.practiceType.rawValue.toInt64
        
        updateData()
        updateSnapshot()
    }
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
        
        cell.configure(row: itemIdentifier)
        
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
