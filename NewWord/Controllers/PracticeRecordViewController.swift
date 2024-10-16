//
//  PracticeRecordViewController.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/10/15.
//

import UIKit

class PracticeRecordViewController: UIViewController {
    
    struct Item: Hashable {
        let learnedDate: Date
        let formattedLearnedDate: String?
        let state: String
        let rate: String
        let interval: String
        let ease: String
    }
    
    struct Section: Hashable {
        var items: [Item]
    }
    
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    private var dataSource: UICollectionViewDiffableDataSource<Section,Item>!
    
    var sections: [Section] = []
    
    var practice: CDPractice?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        setupProperties()
        updateData()
        setupCollectionView()
        updateSnapshot()
    }
    
    private func setupProperties() {
        view.backgroundColor = .background
        self.title = "練習記錄"
    }
    
    private func updateData() {
        guard let standardRecords = practice?.record?.standardRecords else {
            return
        }
        
        var items: [Item] = []
        
        for record in standardRecords {
            guard let learnedDate = record.learnedDate,
                  let stateType = record.stateType,
                  let rate = record.statusType
            else {
                return
            }
            
            let item = Item(learnedDate: learnedDate,
                            formattedLearnedDate: record.formattedLearnedDate,
                            state: stateType.title,
                            rate: rate.title,
                            interval: record.formattedInterval,
                            ease: record.formattedEase)
            
            items.append(item)
        }
        
        items = items.sorted { $0.learnedDate < $1.learnedDate }
        
        sections.append(Section(items: items))
    }
    
    private func setupCollectionView() {
        view.addSubview(collectionView)
        
        dataSource = createCollectionViewDataSource()
        
        collectionView.backgroundColor = .background
        collectionView.frame = view.bounds
        collectionView.register(UINib(nibName: PracticeRecordCell.reuseIdentifier, bundle: nil), forCellWithReuseIdentifier: PracticeRecordCell.reuseIdentifier)
        collectionView.collectionViewLayout = createCollectionViewLayout()
        collectionView.dataSource = dataSource
    }
    
    private func createCollectionViewDataSource() -> UICollectionViewDiffableDataSource<Section, Item> {
        return UICollectionViewDiffableDataSource(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PracticeRecordCell.reuseIdentifier, for: indexPath) as! PracticeRecordCell
            
            cell.updateUI(itemIdentifier)
            
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

extension PracticeRecordViewController {
    
    private func createItem(for section: Section) -> NSCollectionLayoutItem {
        
        let itemSize: NSCollectionLayoutSize
        
        itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(100)
        )
        
        return NSCollectionLayoutItem(layoutSize: itemSize)
    }
    
    private func createGroup(for section: Section, with item: NSCollectionLayoutItem) -> NSCollectionLayoutGroup {
        
        let groupSize: NSCollectionLayoutSize
        
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
    
    private func createSection(for section: Section, with group: NSCollectionLayoutGroup) -> NSCollectionLayoutSection {
        let layoutSection = NSCollectionLayoutSection(group: group)
        layoutSection.contentInsets = NSDirectionalEdgeInsets(top: 15, leading: 15, bottom: 15, trailing: 15)
        
        return layoutSection
    }
}

