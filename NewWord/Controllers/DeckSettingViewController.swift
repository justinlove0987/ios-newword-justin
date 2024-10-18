//
//  DeckSettingViewController.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/10/18.
//

import UIKit

class DeckSettingViewController: UIViewController, PracticeSettingCellProtocol {
    
    struct ThrehsholdsItem: Hashable {
        let thresholds: [CDPracticeThresholdRule]
        let cellContent: PracticeSettingCell.CellContent
    }
    
    enum Item: Hashable {
        case thresholds(ThrehsholdsItem)
    }
    
    struct Section: Hashable {
        var items: [Item]
    }
    
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    private var dataSource: UICollectionViewDiffableDataSource<Section,Item>!
    
    var deck: CDDeck?
    
    var itemTypes: [PracticeSettingCellItemType] = [.threshold]
    
    var sections: [Section] = []
    
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
        self.title = "牌組設定"
    }
    
    private func updateData() {
        for itemType in itemTypes {
            switch itemType {
            case .threshold:
                if let thresholdRules = deck?.preset?.standardPreset?.thresholdRules {
                    let cellContent = PracticeSettingCell.CellContent(title: itemType.title,
                                                                      description: nil,
                                                                      imageName: itemType.sfSymbolName,
                                                                      cellType: itemType.cellType)
                    
                    let thresholdItem = ThrehsholdsItem(thresholds: thresholdRules, cellContent: cellContent)
                    sections.append(Section(items: [Item.thresholds(thresholdItem)]))
                }

            default:
                break
            }
        }
    }
    
    private func setupCollectionView() {
        view.addSubview(collectionView)
        
        collectionView.backgroundColor = .background
        collectionView.frame = view.bounds
        collectionView.register(UINib(nibName: PracticeSettingCell.reuseIdentifier, bundle: nil), forCellWithReuseIdentifier: PracticeSettingCell.reuseIdentifier)
        dataSource = createCollectionViewDataSource()
        collectionView.collectionViewLayout = createCollectionViewLayout()
        collectionView.dataSource = dataSource
        collectionView.delegate = self
    }
    
    private func createCollectionViewDataSource() -> UICollectionViewDiffableDataSource<Section, Item> {
        return UICollectionViewDiffableDataSource(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PracticeSettingCell.reuseIdentifier, for: indexPath) as! PracticeSettingCell
            
            switch itemIdentifier {
            case .thresholds(let thresholdItem):
                cell.updateUI(content: thresholdItem.cellContent)
            }

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

extension DeckSettingViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let section = sections[indexPath.section]
        let item = section.items[indexPath.row]
        
        switch item {
        case .thresholds(let thresholdsItem):
            let controller = PracticeThresholdSettingsViewController()
            controller.thresholds = thresholdsItem.thresholds
            
            navigationController?.pushViewControllerWithCustomTransition(controller)
        }
    }
}


// MARK: - UICollectionViewCompositionalLayout

extension DeckSettingViewController {
    
    private func createItem(for section: Section) -> NSCollectionLayoutItem {
        
        let itemSize: NSCollectionLayoutSize
        
        itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(44)
        )
        
        return NSCollectionLayoutItem(layoutSize: itemSize)
    }
    
    private func createGroup(for section: Section, with item: NSCollectionLayoutItem) -> NSCollectionLayoutGroup {
        
        let groupSize: NSCollectionLayoutSize
        
        groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(44)
        )
        
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize,
            subitems: [item]
        )
        
        return group
        
    }
    
    private func createSection(for section: Section, with group: NSCollectionLayoutGroup) -> NSCollectionLayoutSection {
        let layoutSection = NSCollectionLayoutSection(group: group)
        layoutSection.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0)
        
        return layoutSection
    }
}
