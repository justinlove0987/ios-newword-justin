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
        nameLabel.text = deck?.name
    }
    
    @IBAction func learningOptionsAction(_ sender: UIButton) {
        guard let deck else { return }
        
        let vc = RevisePresetViewController.instantiate()
        vc.deck = deck
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func deleteAction(_ sender: UIButton) {
        guard let deck else { return }
        
        if let index = DeckManager.shared.snapshot.firstIndex(where: { $0 == deck }) {
            DeckManager.shared.remove(at: index)
            NotificationCenter.default.post(name: .deckDidUpdate, object: deck)
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func reviseAction(_ sender: UIButton) {
        guard var deck else { return }
        
        let vc = ReviseNameViewController.instantiate()
        vc.previousName = deck.name
        vc.renameAction = { newName in
            deck.name = newName
            self.nameLabel.text = newName
            DeckManager.shared.update(data: deck)
            NotificationCenter.default.post(name: .deckDidUpdate, object: deck)
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
