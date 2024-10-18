//
//  PracticeThresholdSettingsViewController.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/10/17.
//

import UIKit

class PracticeThresholdSettingsViewController: UIViewController {
    
    typealias Item = CDPracticeThresholdRule
    
    struct Section: Hashable {
        var items: [Item]
    }
    
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    private var dataSource: UICollectionViewDiffableDataSource<Section,Item>!
    
    var sections: [Section] = []
    
    var thresholds: [CDPracticeThresholdRule] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        updateData()
        setupProperties()
        setupCollectionView()
        updateSnapshot()
    }
    
    private func setupProperties() {
        self.title = "練習次數設定"
    }
    
    private func updateData() {
        var thresholds: [CDPracticeThresholdRule] = []
        
        thresholds = self.thresholds
        
        sections.append(Section(items: thresholds))
    }
    
    private func setupCollectionView() {
        view.backgroundColor = .background
        view.addSubview(collectionView)
        
        collectionView.frame = view.bounds
        collectionView.backgroundColor = .background
        collectionView.register(UINib(nibName: PracticeThresholdCell.reuseIdentifier, bundle: nil), forCellWithReuseIdentifier: PracticeThresholdCell.reuseIdentifier)
        dataSource = createCollectionViewDataSource()
        
        collectionView.collectionViewLayout = createCollectionViewLayout()
        collectionView.dataSource = dataSource
    }
    
    private func createCollectionViewDataSource() -> UICollectionViewDiffableDataSource<Section, Item> {
        return UICollectionViewDiffableDataSource(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PracticeThresholdCell.reuseIdentifier, for: indexPath) as! PracticeThresholdCell
            cell.updateUI(threshold: itemIdentifier)
            return cell
        }
    }
    
    private func createCollectionViewLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { [weak self] (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            guard let self = self else { return nil }
            
            let sectionIdentifier = sections[sectionIndex]
            
            let item = self.createItem(for: sectionIdentifier)
            let group = self.createGroup(for: sectionIdentifier, with: item)
            let section = self.createSection(for: sectionIdentifier, with: group)
            
            return section
        }
    }
    
    private func updateSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        
        for section in sections {
            snapshot.appendSections([section])
            snapshot.appendItems(section.items, toSection: section)
        }
        
        dataSource.apply(snapshot)
    }
    
}


// MARK: - UICollectionViewCompositionalLayout

extension PracticeThresholdSettingsViewController {
    
    private func createItem(for section: Section) -> NSCollectionLayoutItem {
        
        let itemSize: NSCollectionLayoutSize
        
        itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(44)
        )
        
        return NSCollectionLayoutItem(layoutSize: itemSize)
    }
    
    private func createGroup(for section: Section, with item: NSCollectionLayoutItem) -> NSCollectionLayoutGroup {
        
        let groupSize: NSCollectionLayoutSize
        
        groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(44)
        )
        
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize,
            subitems: [item]
        )
        
        return group
        
    }
    
    private func createSection(for section: Section, with group: NSCollectionLayoutGroup) -> NSCollectionLayoutSection {
        let layoutSection = NSCollectionLayoutSection(group: group)
        
        return layoutSection
    }
}

