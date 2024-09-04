//
//  PracticeSequenceViewController.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/8/26.
//

import UIKit

class PracticeSequenceViewController: UIViewController, StoryboardGenerated {
    
    struct PracticeSetting: Hashable {
        var title: String
        var id: String = UUID().uuidString
    }
    
    static var storyboardName: String = K.Storyboard.main
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var dataSource: UICollectionViewDiffableDataSource<Int,Practice>!

    private var practiceMap: PracticeMap?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        setupData()
        setupCollectionView()
    }

    private func setupData() {
        self.practiceMap = PracticeMapManager.shared.fetch(by: PracticeMapType.blueprint.rawValue)
    }

    private func setupCollectionView() {
        collectionView.register(UINib(nibName: PracticeSequenceCell.reuseIdentifier, bundle: nil).self, forCellWithReuseIdentifier: PracticeSequenceCell.reuseIdentifier)
        dataSource = createDataSource()
        collectionView.dataSource = dataSource
        collectionView.collectionViewLayout = createCollectionViewLayout()
        collectionView.delegate = self
        updateSnapshot()
    }

    private func createDataSource() -> UICollectionViewDiffableDataSource<Int, Practice> {
        let dataSource = UICollectionViewDiffableDataSource<Int, Practice>(collectionView: collectionView,
                                                                            cellProvider: { collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PracticeSequenceCell.reuseIdentifier, for: indexPath) as! PracticeSequenceCell
            
            cell.titleLabel.text = itemIdentifier.type?.title

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
    
    private func updateSnapshot() {
        guard let practiceMap else { return }

        var snapshot = NSDiffableDataSourceSnapshot<Int, Practice>()

        for i in 0..<practiceMap.sequences.count {
            let sequence = practiceMap.sequences[i]

            snapshot.appendSections([i])
            snapshot.appendItems(sequence.practices, toSection: i)
        }
        
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}

extension PracticeSequenceViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let practiceMap else { return }
        
        let sequence = practiceMap.sequences[indexPath.section]
        let practice = sequence.practices[indexPath.row]
        
        let controller = PracticeSettingViewController.instantiate()
        
        controller.practice = practice
        
        navigationController?.pushViewControllerWithCustomTransition(controller)
    }
}
