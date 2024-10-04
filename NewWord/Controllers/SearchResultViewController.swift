//
//  SearchResultViewController.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/10/4.
//

import UIKit

class SearchResultViewController: UIViewController {
    
    struct Item: Hashable {
        var practiceContext: CDPracticeContext
    }
    
    struct Section: Hashable {
        var items: [Item]
    }
    
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    private var dataSource: UICollectionViewDiffableDataSource<Section,Item>!
    
    var sections: [Section] = []
    
    var practiceLemma: CDPracticeLemma?

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        updateData()
        setupCollectionView()
        updateSnapshot()
    }
    
    private func updateData() {
        guard let practiceLemma else {
            return
        }
        
        let items = practiceLemma.contexts.map { context in
            Item(practiceContext: context)
        }
        
        sections = [Section(items: items)]
    }
    
    private func setupCollectionView() {
        collectionView.frame = view.bounds
        collectionView.register(SearchResultCell.self, forCellWithReuseIdentifier: SearchResultCell.reuseIdentifier)
        dataSource = createCollectionViewDataSource()
        
        collectionView.collectionViewLayout = createCollectionViewLayout()
        collectionView.dataSource = dataSource
    }
    
    private func createCollectionViewDataSource() -> UICollectionViewDiffableDataSource<Section, Item> {
        return UICollectionViewDiffableDataSource(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchResultCell.reuseIdentifier, for: indexPath) as! SearchResultCell
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

extension SearchResultViewController {

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
