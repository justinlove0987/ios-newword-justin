//
//  SearchResultViewController.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/10/4.
//

import UIKit

class SearchResultViewController: UIViewController {
    
    struct HighlightContext: Hashable {
        let id = UUID().uuidString
        let articleId: String
        let text: String
        let highlightRange: NSRange
    }
    
    struct Record: Hashable {
        let id = UUID().uuidString
    }

    enum Item: Hashable {
        case record(Record)
        case highlightContext(HighlightContext)
    }
    
    enum Section: Hashable {
        case record([Item])
        case highlightContext([Item])
    }
    
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    private var dataSource: UICollectionViewDiffableDataSource<Section,Item>!
    
    var sections: [Section] = []
    
    var practiceLemma: CDPracticeLemma?

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateData()
        updateSnapshot()
    }
    
    private func setup() {
        updateData()
        setupProperties()
        setupCollectionView()
        updateSnapshot()
    }
    
    private func updateData() {
        guard let practiceLemma else { return }
        
        let items = collectItems(from: practiceLemma.contexts)
        sections = createSections(from: items)
    }

    private func collectItems(from contexts: [CDPracticeContext]) -> [Item] {
        var items: [Item] = []
        
        for context in contexts {
            guard let sortedSequences = context.map?.sortedSequences else { return items }
            
            for sequence in sortedSequences {
                
                for practice in sequence.sortedPractices {
                    guard let article = practice.serverProviededContent?.article,
                          let articleId = article.id,
                          let articleText = article.text,
                          let highlightRange = practice.userGeneratedContent?.userGeneratedContextTag?.range else {
                        continue
                    }
                    
                    let highlightContext = HighlightContext(articleId: articleId, text: articleText, highlightRange: highlightRange)
                    
                    if !isContextDuplicate(highlightContext, in: items) {
                        let item = Item.highlightContext(highlightContext)
                        
                        items.append(item)
                    }
                }
            }
        }
        
        return items
    }

    private func isContextDuplicate(_ highlightContext: HighlightContext, in items: [Item]) -> Bool {
        return items.contains {
            if case let .highlightContext(existingContext) = $0 {
                return existingContext.articleId == highlightContext.articleId &&
                existingContext.highlightRange == highlightContext.highlightRange
            }
            return false
        }
    }

    private func createSections(from items: [Item]) -> [Section] {
        var sections: [Section] = []
        
//        for _ in 1...3 {
//            sections.append(Section.record([Item.record(Record()), Item.record(Record()), Item.record(Record())]))
//        }
        
        sections.append(Section.highlightContext(items))
        
        return sections
    }
    
    private func setupProperties() {
        self.title = "同詞彙列表"
        self.view.backgroundColor = .background
    }
    
    private func setupCollectionView() {
        self.view.addSubview(collectionView)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
        
        collectionView.backgroundColor = .transition
        collectionView.frame = view.bounds
        collectionView.register(UINib(nibName: SearchResultCell.reuseIdentifier, bundle: nil), forCellWithReuseIdentifier: SearchResultCell.reuseIdentifier)
        dataSource = createCollectionViewDataSource()
        
        collectionView.collectionViewLayout = createCollectionViewLayout()
        collectionView.dataSource = dataSource
    }
    
    private func createCollectionViewDataSource() -> UICollectionViewDiffableDataSource<Section, Item> {
        return UICollectionViewDiffableDataSource(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchResultCell.reuseIdentifier, for: indexPath) as! SearchResultCell
            
            cell.configureUI(itemIdentifier: itemIdentifier)
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
            
            switch section {
            case .record(let items), .highlightContext(let items):
                snapshot.appendItems(items, toSection: section)
            }
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
            heightDimension: .fractionalHeight(1.0)
        )

        return NSCollectionLayoutItem(layoutSize: itemSize)
    }

    private func createGroup(for section: Section, with item: NSCollectionLayoutItem) -> NSCollectionLayoutGroup {
        
        let groupSize: NSCollectionLayoutSize
        
        switch section {
        case .record(_):
            groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(0.3),
                heightDimension: .fractionalWidth(0.3)
            )

            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize,
                subitems: [item]
            )
            
            return group
            
        case .highlightContext(_):
            groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(150)
            )

            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: groupSize,
                subitems: [item]
            )
            
            return group
        }
    }

    private func createSection(for section: Section, with group: NSCollectionLayoutGroup) -> NSCollectionLayoutSection {
        let layoutSection = NSCollectionLayoutSection(group: group)
        
        layoutSection.contentInsets = NSDirectionalEdgeInsets(top: 15, leading: 20, bottom: 15, trailing: 20)
        layoutSection.interGroupSpacing = 20
        
        switch section {
        case .record(_):
            layoutSection.orthogonalScrollingBehavior = .continuous
        default:
            break
        }

        return layoutSection
    }
}
