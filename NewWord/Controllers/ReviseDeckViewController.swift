//
//  ReviseDeckViewController.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/5/30.
//

import UIKit

class ReviseDeckViewController: UIViewController, StoryboardGenerated {
    
    static var storyboardName: String = K.Storyboard.main
    
    @IBOutlet weak var nameLabel: UILabel!
    
    var deck: CDDeck?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }

    // MARK: - Helpers
    
    func updateUI() {
        nameLabel.text = deck?.name
    }
    
    // MARK: - Actions
    
    @IBAction func learningOptionsAction(_ sender: UIButton) {
        guard let deck else { return }
        
        let vc = RevisePresetViewController.instantiate()
        vc.deck = deck
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func deleteAction(_ sender: UIButton) {
        guard let deck else { return }

        CoreDataManager.shared.deleteDeck(deck)
        NotificationCenter.default.post(name: .deckDidUpdate, object: deck)
        
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func reviseAction(_ sender: UIButton) {
        guard let deck else { return }
        
        let vc = ReviseNameViewController.instantiate()
        
        vc.previousName = deck.name
        
        vc.renameAction = { newName in
            CoreDataManager.shared.updateDeckName(deck, newName)
            self.updateUI()
            NotificationCenter.default.post(name: .deckDidUpdate, object: deck)
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

// MARK: - ReviseDeckViewControllerDelegate

extension ReviseDeckViewController: RevisePresetViewControllerDelegate {
    func didTapSaveButton(_ controller: RevisePresetViewController) {
        updateUI()
    }
}
