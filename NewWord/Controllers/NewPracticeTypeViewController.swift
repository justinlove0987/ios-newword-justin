//
//  NewPracticeTypeViewController.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/10/1.
//

import UIKit

// Subclass for PracticeType
class NewPracticeTypeViewController: ReusableCollectionViewController<PracticeType> {
    
    var practice: CDPractice?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupData()
        setupProperties()
    }
    
    private func setupData() {
        self.title = "練習種類"
        self.items = PracticeType.allCases
        
        guard let practiceType = practice?.type else { return }
        
        for currentPracticeType in PracticeType.allCases {
            let isSelected = currentPracticeType.rawValue == practiceType.rawValue
            
            if isSelected {
                self.selectedItem = currentPracticeType
            }
        }
    }
    
    private func setupProperties() {
        view.backgroundColor = .background
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        super.collectionView(collectionView, didSelectItemAt: indexPath)
        
        let selectedPracticeType = items[indexPath.row]
        
        practice?.typeRawValue = selectedPracticeType.rawValue.toInt64
        
        print("Selected practice type: \(selectedPracticeType)")
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
}

