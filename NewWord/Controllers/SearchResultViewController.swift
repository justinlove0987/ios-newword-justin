//
//  SearchResultViewController.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/10/4.
//

import UIKit

class SearchResultViewController: UIViewController, StoryboardGenerated {
    
    static var storyboardName: String = K.Storyboard.main
    
    struct HighlightContext: Hashable {
        let id = UUID().uuidString
        let articleId: String
        let text: String
        let highlightRange: NSRange
    }
    
    struct HighlightContexts: Hashable {
        let text: String
        let practiceContext: CDPracticeContext
        let items: [Item]
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
        case highlightContext(HighlightContexts)
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    
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

        var sections: [Section] = []
        
        for context in practiceLemma.contexts {
            guard let sortedSequences = context.map?.sortedSequences else { continue }
            guard let text = context.context else { return }
            
            let items = getItems(from: sortedSequences)
            
            let section = Section.highlightContext(HighlightContexts(text: text,
                                                                     practiceContext: context,
                                                                     items: items))
            
            sections.append(section)
        }
        
        self.sections = sections
    }

    private func getItems(from sequences: [CDPracticeSequence]) -> [Item] {
        var items: [Item] = []
        
        for sequence in sequences {
            for practice in sequence.sortedPractices {
                if let highlightContext = createHighlightContext(from: practice),
                   !isContextDuplicate(highlightContext, in: items) {
                    items.append(Item.highlightContext(highlightContext))
                }
            }
        }
        
        return items
    }

    private func createHighlightContext(from practice: CDPractice) -> HighlightContext? {
        guard let article = practice.serverProviededContent?.article,
              let articleId = article.id,
              let articleText = article.text,
              let highlightRange = practice.userGeneratedContent?.userGeneratedContextTag?.range else {
            return nil
        }
        
        return HighlightContext(articleId: articleId, text: articleText, highlightRange: highlightRange)
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
    
    private func setupProperties() {
        self.title = practiceLemma?.lemma ?? "同詞彙列表"
        self.view.backgroundColor = .background
        self.navigationController?.navigationBar.tintColor = UIColor.title
    }
    
    private func setupCollectionView() {
        collectionView.backgroundColor = .transition
        
        // 註冊 Cell
        collectionView.register(UINib(nibName: SearchResultCell.reuseIdentifier, bundle: nil), forCellWithReuseIdentifier: SearchResultCell.reuseIdentifier)
        
        // 註冊 Header
        collectionView.register(UINib(nibName: SearchResultHeaderView.reuseIdentifier, bundle: nil),
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: SearchResultHeaderView.reuseIdentifier)
        
        dataSource = createCollectionViewDataSource()
        
        collectionView.collectionViewLayout = createCollectionViewLayout()
        collectionView.dataSource = dataSource
    }
    
    private func createCollectionViewDataSource() -> UICollectionViewDiffableDataSource<Section, Item> {
        let dataSource =  UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchResultCell.reuseIdentifier, for: indexPath) as! SearchResultCell
            
            cell.configureUI(itemIdentifier: itemIdentifier)
            return cell
        }
        
        dataSource.supplementaryViewProvider = supplementaryViewProvider
        
        return dataSource
    }
    
    private func createCollectionViewLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { [weak self] (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            guard let self = self else { return nil }
            
            let sectionIdentifier = sections[sectionIndex]

            // 配置 Item
            let item = self.createItem(for: sectionIdentifier)
            
            // 配置 Group
            let group = self.createGroup(for: sectionIdentifier, with: item)
            
            // 配置 Section
            let section = self.createSection(for: sectionIdentifier, with: group)
            
            
            // 配置 Header
            if let headerItem = self.createHeader(for: sectionIndex) {
                section.boundarySupplementaryItems.append(headerItem)
            }

            return section
        }
    }
    
    private func updateSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        
        for section in sections {
            snapshot.appendSections([section])
            
            switch section {
            case .record(let items):
                snapshot.appendItems(items, toSection: section)
                
            case .highlightContext(let highlightContexts):
                snapshot.appendItems(highlightContexts.items, toSection: section)
            }
        }

        dataSource.apply(snapshot)
    }
}

// MARK: - UICollectionView DataSource

extension SearchResultViewController {
    
    // 提供 Supplementary View 的配置方法
    private func supplementaryViewProvider(
        collectionView: UICollectionView,
        kind: String,
        indexPath: IndexPath
    ) -> UICollectionReusableView? {
        if kind == UICollectionView.elementKindSectionHeader {
            return configureHeaderView(collectionView: collectionView, indexPath: indexPath)
        }
        
        return nil
    }
    
    private func configureHeaderView(
        collectionView: UICollectionView,
        indexPath: IndexPath
    ) -> UICollectionReusableView? {
        let headerView = collectionView.dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: SearchResultHeaderView.reuseIdentifier,
            for: indexPath
        ) as! SearchResultHeaderView
        
        let section = self.sections[indexPath.section]
        
        if case let .highlightContext(highlightContexts) = section {
            headerView.updateUI(title: highlightContexts.text)
            
            headerView.recordCallback = { [weak self] in
                guard let self else { return }
                
                let controller = PracticeMapViewController.instantiate()
                controller.practiceMap = highlightContexts.practiceContext.map
                
                self.navigationController?.pushViewControllerWithCustomTransition(controller)
            }
        }

        return headerView
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
    
    private func createHeader(for sectionIndex: Int) -> NSCollectionLayoutBoundarySupplementaryItem? {
        
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(15)
        )
        
        return NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
    }
}


