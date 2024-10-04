//
//  PracticeSettingViewController.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/8/26.
//

import UIKit

class PracticeSettingViewController: UIViewController, StoryboardGenerated {
    
    enum Section: Hashable {
        case practiceTypeAndDetails
        case firstPractice
        case forget
        case advanced
        
        var rows: [Row] {
            switch self {
            case .practiceTypeAndDetails:
                return [.practiceType, .deck]
            case .firstPractice:
                return [.firstPracticeLearningPhase, .firstPracticeGraduationInterval, .firstPracticeEasyInterval]
            case .forget:
                return [.forgotRelearningPhase, .forgotGraduationInterval]
            case .advanced:
                return [.initialEase, .followPreviousPractice, .practiceCompletionRules]
            }
        }
        
        var title: String? {
            switch self {
            case .firstPractice:
                return "第一次練習"
            case .forget:
                return "忘記"
            case .advanced:
                return "進階設定"
                
            default:
                return nil
            }
        }
    }
    
    enum Row: Hashable {
        
        enum CellType {
            case navigation    // 轉跳畫面的 cell
            case information   // 顯示資訊的 cell
            case toggleSwitch  // 有 switch 開關的 cell
        }
        
        case practiceType
        case firstPracticeLearningPhase
        case firstPracticeGraduationInterval
        case firstPracticeEasyInterval
        case forgotRelearningPhase
        case forgotGraduationInterval
        case initialEase
        case followPreviousPractice
        case practiceCompletionRules
        case deck
        
        var cellType: CellType {
            switch self {
            case .practiceType:
                return .navigation
            case .firstPracticeLearningPhase:
                return .information
            case .firstPracticeGraduationInterval:
                return .information
            case .firstPracticeEasyInterval:
                return .information
            case .forgotRelearningPhase:
                return .information
            case .forgotGraduationInterval:
                return .information
            case .initialEase:
                return .information
            case .followPreviousPractice:
                return .toggleSwitch
            case .practiceCompletionRules:
                return .navigation
            case .deck:
                return .navigation
            }
        }
        
        var title: String {
            switch self {
            case .practiceType:
                return "練習種類"
            case .firstPracticeLearningPhase:
                return "畢業階段"
            case .firstPracticeGraduationInterval:
                return "畢業間隔"
            case .firstPracticeEasyInterval:
                return "畢業階段"
            case .forgotRelearningPhase:
                return "重新學習階段"
            case .forgotGraduationInterval:
                return "畢業間隔"
            case .initialEase:
                return "起始輕鬆度"
            case .followPreviousPractice:
                return "緊接上一個練習"
            case .practiceCompletionRules:
                return "練習畢業規則"
            case .deck:
                return "練習牌組"
            }
        }
        
        var sfSymbolName: String {
            switch self {
            case .practiceType:
                return "list.bullet"
            case .firstPracticeLearningPhase:
                return "graduationcap"
            case .firstPracticeGraduationInterval:
                return "calendar"
            case .firstPracticeEasyInterval:
                return "clock"
            case .forgotRelearningPhase:
                return "arrow.uturn.backward"
            case .forgotGraduationInterval:
                return "calendar.badge.clock"
            case .initialEase:
                return "dial"
            case .followPreviousPractice:
                return "arrow.turn.down.right"
            case .practiceCompletionRules:
                return "doc.text.magnifyingglass"
            case .deck:
                return "sparkles.rectangle.stack"
            }
        }
    }
    
    struct PracticeSetting: Hashable {
        var title: String
        var id: String = UUID().uuidString
    }
    
    static var storyboardName: String = K.Storyboard.main
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var dataSource: UICollectionViewDiffableDataSource<Section,Row>!
    
    private var sections: [Section] = [.practiceTypeAndDetails]
    
    var practice: CDPractice?

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        setupProperties()
        setupCollectionView()
    }
    
    private func setupProperties() {
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem

        self.title = "練習地圖設定"
    }

    private func setupCollectionView() {
        collectionView.register(UINib(nibName: PracticeSettingCell.reuseIdentifier, bundle: nil).self, forCellWithReuseIdentifier: PracticeSettingCell.reuseIdentifier)
        collectionView.register(UINib(nibName: PracticeSettingHeaderView.reuseIdentifier, bundle: nil).self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: PracticeSettingHeaderView.reuseIdentifier)
        collectionView.register(SeparatorFooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: SeparatorFooterView.reuseIdentifier)
        dataSource = createDataSource()
        collectionView.dataSource = dataSource
        collectionView.collectionViewLayout = createCollectionViewLayout()
        collectionView.delegate = self
        updateSnapshot()
    }

    private func createDataSource() -> UICollectionViewDiffableDataSource<Section, Row> {
        // 建立 DataSource
        let dataSource = UICollectionViewDiffableDataSource<Section, Row>(
            collectionView: collectionView,
            cellProvider: cellProvider
        )
        
        // 配置 Supplementary View
        dataSource.supplementaryViewProvider = supplementaryViewProvider
        
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
            
            // 配置 Header
            if let headerItem = self.createHeader(for: sectionIndex) {
                section.boundarySupplementaryItems.append(headerItem)
            }
            
            // 配置 Footer
            if sectionIndex < self.sections.count - 1 {  // 確保不是最後一個 section
                let footerItem = self.createFooter()
                section.boundarySupplementaryItems.append(footerItem)
            }
            
            return section
        }
    }
    
    private func updateSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Row>()
        
        for i in 0..<sections.count {
            let section = sections[i]
            
            snapshot.appendSections([section])
            snapshot.appendItems(section.rows, toSection: section)
        }
        
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}

extension PracticeSettingViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let section = sections[indexPath.section]
        let row = section.rows[indexPath.row]
                
        switch row {
        case .practiceType:
            let controller = SelectPracticeTypeViewController()
            controller.practiceBlueprint = practice
            navigationController?.pushViewControllerWithCustomTransition(controller)
            
        case .deck:
            let controller = SelectDeckViewController()
            controller.blueprintPractice = practice
            navigationController?.pushViewControllerWithCustomTransition(controller)
            
        case .practiceCompletionRules:
            let controller = PracticeCompletionViewController.instantiate()
            navigationController?.pushViewControllerWithCustomTransition(controller)
            
        default:
            break
        }
    }
}

// MARK: - UICollectionView DataSource

extension PracticeSettingViewController {
    
    // 提供 Cell 的配置方法
    private func cellProvider(
        collectionView: UICollectionView,
        indexPath: IndexPath,
        itemIdentifier: Row
    ) -> UICollectionViewCell? {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PracticeSettingCell.reuseIdentifier, for: indexPath) as! PracticeSettingCell
        
        if let practice {
            cell.configure(row: itemIdentifier, data: practice)
        }
        
        return cell
    }

    // 提供 Supplementary View 的配置方法
    private func supplementaryViewProvider(
        collectionView: UICollectionView,
        kind: String,
        indexPath: IndexPath
    ) -> UICollectionReusableView? {
        if kind == UICollectionView.elementKindSectionHeader {
            return configureHeaderView(collectionView: collectionView, indexPath: indexPath)
        } else if kind == UICollectionView.elementKindSectionFooter {
            return configureFooterView(collectionView: collectionView, indexPath: indexPath)
        }
        return nil
    }

    // 配置 Header View
    private func configureHeaderView(
        collectionView: UICollectionView,
        indexPath: IndexPath
    ) -> UICollectionReusableView? {
        let headerView = collectionView.dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: PracticeSettingHeaderView.reuseIdentifier,
            for: indexPath
        ) as! PracticeSettingHeaderView
        
        let section = self.sections[indexPath.section]
        if let title = section.title {
            headerView.configure(with: title)
        }
        
        return headerView
    }

    // 配置 Footer View
    private func configureFooterView(
        collectionView: UICollectionView,
        indexPath: IndexPath
    ) -> UICollectionReusableView? {
        let footerView = collectionView.dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: SeparatorFooterView.reuseIdentifier,
            for: indexPath
        ) as! SeparatorFooterView
        
        return footerView
    }
}


// MARK: - UICollectionViewCompositionalLayout

extension PracticeSettingViewController {
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
    
    // 配置 Header
    private func createHeader(for sectionIndex: Int) -> NSCollectionLayoutBoundarySupplementaryItem? {
        guard self.sections[sectionIndex].title != nil else { return nil }
        
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
    
    // 配置 Footer
    private func createFooter() -> NSCollectionLayoutBoundarySupplementaryItem {
        let footerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(8)
        )
        
        return NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: footerSize,
            elementKind: UICollectionView.elementKindSectionFooter,
            alignment: .bottom
        )
    }
}
