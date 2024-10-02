//
//  NewPracticeTypeViewController.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/10/1.
//

import UIKit

// Subclass for PracticeType
class SelectPracticeTypeViewController: ReusableCollectionViewController<PracticeType> {
    
    var practiceBlueprint: CDPractice?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupData()
        setupProperties()
    }
    
    private func setupData() {
        self.items = PracticeType.allCases
        
        guard let practiceType = practiceBlueprint?.type else { return }
        
        for currentPracticeType in PracticeType.allCases {
            let isSelected = currentPracticeType.rawValue == practiceType.rawValue
            
            if isSelected {
                self.selectedItem = currentPracticeType
            }
        }
    }
    
    private func setupProperties() {
        self.title = "練習種類"
        view.backgroundColor = .background
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        super.collectionView(collectionView, didSelectItemAt: indexPath)
        
        let selectedPracticeType = items[indexPath.row]

        updateData(with: selectedPracticeType)

    }
    
    override func cellProvider(
        collectionView: UICollectionView,
        indexPath: IndexPath,
        itemIdentifier: Row
    ) -> UICollectionViewCell? {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RadioButtonCell.reuseIdentifier, for: indexPath) as! RadioButtonCell
        cell.configure(row: itemIdentifier)
        return cell
    }

    private func updateData(with selectedPracticeType: PracticeType) {
        practiceBlueprint?.typeRawValue = selectedPracticeType.rawValue.toInt64

        guard let deckGenerationType = practiceBlueprint?.deck?.generationType,
              deckGenerationType == .systemGenerated else {
            return
        }

        practiceBlueprint?.deck = CoreDataManager.shared.getAll(ofType: CDDeck.self)
            .first { $0.generationType == .systemGenerated && $0.practiceType == selectedPracticeType }
    }

}

