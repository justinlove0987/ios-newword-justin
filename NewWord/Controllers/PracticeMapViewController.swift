//
//  PracticeSequenceViewController.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/8/26.
//

import UIKit

class PracticeMapViewController: UIViewController, StoryboardGenerated {
    
    enum CellType {
        case addPractice
        case practice
    }
    
    struct Item: Hashable {
        var id: UUID = UUID()
        var cellType: CellType
        var practice: CDPractice?
    }
    
    static var storyboardName: String = K.Storyboard.main
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var dataSource: UICollectionViewDiffableDataSource<Int,Item>!

    var practiceMap: CDPracticeMap?
    
    var itemMatrix: [[Item]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
    }
    
    private func setup() {
        setupProperties()
        setupData()
        setupCollectionView()
    }
    
    private func setupProperties() {
        self.title = "練習地圖"
    }
    
    private func setupData() {
        guard let practiceMap else { return }
        
        itemMatrix = []
        
        for i in 0..<practiceMap.sortedSequences.count {
            let sequence = practiceMap.sortedSequences[i]
            
            let isLastSeqeunce = i + 1 == practiceMap.sortedSequences.count
            var items: [Item] = []
            
            for j in 0..<sequence.sortedPractices.count {
                let practice = sequence.sortedPractices[j]
                
                let isLastPractice = j + 1 == sequence.sortedPractices.count
                
                let pracitceItem = Item(cellType: .practice, practice: practice)
                items.append(pracitceItem)
                
                if isLastPractice {
                    let addPracticeItem = Item(cellType: .addPractice)
                    items.append(addPracticeItem)
                }
            }
            
            itemMatrix.append(items)
            
            if isLastSeqeunce {
                let addPracticeItem = Item(cellType: .addPractice)
                let newSeqeunce = [addPracticeItem]
                
                itemMatrix.append(newSeqeunce)
            }
        }
    }

    private func setupCollectionView() {
        collectionView.register(UINib(nibName: PracticeSequenceCell.reuseIdentifier, bundle: nil).self, forCellWithReuseIdentifier: PracticeSequenceCell.reuseIdentifier)
        dataSource = createDataSource()
        collectionView.dataSource = dataSource
        collectionView.collectionViewLayout = createCollectionViewLayout()
        collectionView.delegate = self
        updateSnapshot(false)
    }

    private func createDataSource() -> UICollectionViewDiffableDataSource<Int, Item> {
        let dataSource = UICollectionViewDiffableDataSource<Int, Item>(collectionView: collectionView,
                                                                            cellProvider: { collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PracticeSequenceCell.reuseIdentifier, for: indexPath) as! PracticeSequenceCell
            
            switch itemIdentifier.cellType {
            case .addPractice:
                cell.titleLabel.text = "+"
                
            case .practice:
                cell.titleLabel.text = itemIdentifier.practice?.type?.title
            }

            return cell
        })
        
        return dataSource
    }
    
    private func createCollectionViewLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .estimated(100),
            heightDimension: .estimated(100)
        )
        
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 20  // 可選：設置組之間的間距
        section.contentInsets = NSDirectionalEdgeInsets(top: 15, leading: 15, bottom: 15, trailing: 15)
        section.orthogonalScrollingBehavior = .continuous
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    private func updateSnapshot(_ animatingDifferences: Bool) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, Item>()

        for i in 0..<itemMatrix.count {
            let items = itemMatrix[i]

            snapshot.appendSections([i])
            snapshot.appendItems(items, toSection: i)
        }
        
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
}

extension PracticeMapViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let practiceMap else { return }
        
        let items = itemMatrix[indexPath.section]
        let item = items[indexPath.row]
        
        switch item.cellType {
        case .addPractice:
            let hasSequence = indexPath.section < practiceMap.sortedSequences.count
            
            if hasSequence {
                let seqeunce = practiceMap.sortedSequences[indexPath.section]

                let practiceBlueprint = createPracticeBlueprint()
                practiceBlueprint.sequence = seqeunce
                practiceBlueprint.order = indexPath.row.toInt64
                practiceBlueprint.sequence = seqeunce
                
                let item = Item(cellType: .practice, practice: practiceBlueprint)
                
                itemMatrix[indexPath.section].insert(item, at: indexPath.row)
                
            } else {
                let newSeqeunce = CoreDataManager.shared.createEntity(ofType: CDPracticeSequence.self)
                
                let practiceBlueprint = createPracticeBlueprint()
                practiceBlueprint.sequence = newSeqeunce
                practiceBlueprint.order = indexPath.row.toInt64
                practiceBlueprint.sequence = newSeqeunce
                
                newSeqeunce.map = practiceMap
                newSeqeunce.level = indexPath.section.toInt64
                
                let item = Item(cellType: .practice, practice: practiceBlueprint)
                itemMatrix[indexPath.section].insert(item, at: indexPath.row)
                
                let addPracticeItem = Item(cellType: .addPractice)
                itemMatrix.append([addPracticeItem])
            }
            
            CoreDataManager.shared.save()
            
            updateSnapshot(true)
            
        case .practice:
            let controller = PracticeSettingViewController.instantiate()
            controller.practice = item.practice
            navigationController?.pushViewControllerWithCustomTransition(controller)
        }
    }
}


// MARK: - CoreData

extension PracticeMapViewController {
    
    func createPracticeBlueprint() -> CDPractice {
        let practiceBlueprint = CoreDataManager.shared.createEntity(ofType: CDPractice.self)
        
        practiceBlueprint.typeRawValue = PracticeType.listenAndTranslate.rawValue.toInt64
        
        return practiceBlueprint
    }
}
