//
//  PracticeCompletionViewController.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/9/30.
//

import UIKit

class PracticeCompletionViewController: UIViewController, StoryboardGenerated {
    
    static var storyboardName: String = K.Storyboard.main

    @IBOutlet weak var collectionView: UICollectionView!
    
    
    private var dataSource: UICollectionViewDiffableDataSource<Int,Row>!
    
    struct Row: Hashable {
        var practiceThreshold: CDPracticeThresholdRule?
    }
    
    var rows: [Row] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        setupData()
        setupProperties()
        setupCollectionView()
        updateSnapshot()
    }
    
    private func setupData() {
        let rule = CoreDataManager.shared.createEntity(ofType: CDPracticeThresholdRule.self)
        
        rule.conditionTypeRawValue = PracticeThresholdRuleConditionType.totalAgainAttempts.rawValue.toInt64
        rule.thresholdValue = 3.toInt64
        
        rows.append(Row(practiceThreshold: rule))
    }
    
    private func setupProperties() {
        self.title = "練習畢業規則"
    }
    
    private func setupCollectionView() {
        collectionView.register(UINib(nibName: PracticeCompletionCollectionViewCell.reuseIdentifier, bundle: nil).self, forCellWithReuseIdentifier: PracticeCompletionCollectionViewCell.reuseIdentifier)
        
        dataSource = createDataSource()
        collectionView.dataSource = dataSource
        collectionView.collectionViewLayout = createCollectionViewLayout()
        collectionView.delegate = self
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
            
            let item = self.createItem()
            let group = self.createGroup(with: item)
            let section = self.createSection(with: group)
            
            return section
        }
    }
    
    private func updateSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Int, Row>()
        
        let sectionIdentifier = 0
        
        snapshot.appendSections([sectionIdentifier])
        snapshot.appendItems(rows, toSection: sectionIdentifier)
        
        dataSource.apply(snapshot, animatingDifferences: false)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        if let touch = touches.first {
            let location = touch.location(in: self.collectionView)
            print("Touch began at location: \(location)")
        }
    }
}

// MARK: - UICollectionView Delegate

extension PracticeCompletionViewController: UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        
        for cell in collectionView.visibleCells {
            guard let cell = cell as? PracticeCompletionCollectionViewCell else {
                return
            }
            
            if cell.textField.isFirstResponder {
                cell.textField.resignFirstResponder()
            }
        }
    }
}

// MARK: - UICollectionView DataSource

extension PracticeCompletionViewController {
    
    private func cellProvider(
        collectionView: UICollectionView,
        indexPath: IndexPath,
        itemIdentifier: Row
    ) -> UICollectionViewCell? {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PracticeCompletionCollectionViewCell.reuseIdentifier, for: indexPath) as! PracticeCompletionCollectionViewCell
        
        cell.itemIdentifier = itemIdentifier
        cell.updateUI()
        
        return cell
    }
}

// MARK: - UICollectionViewCompositionalLayout

extension PracticeCompletionViewController {
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
