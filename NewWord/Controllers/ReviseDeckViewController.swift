//
//  ReviseDeckViewController.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/5/6.
//

import UIKit

protocol ReviseDeckViewControllerDelegate: AnyObject {
    func didTapSaveButton(_ controller: ReviseDeckViewController, revisedDeck: Deck)
}

class ReviseDeckViewController: UIViewController {
    
    @IBOutlet weak var learningStepsTextField: UITextField!
    @IBOutlet weak var learningGraduatingIntervalTextField: UITextField!
    @IBOutlet weak var easyIntervalTextField: UITextField!
    @IBOutlet weak var relearningStepsTextField: UITextField!
    @IBOutlet weak var minumumIntervalTextField: UITextField!
    @IBOutlet weak var leachThresholdTextField: UITextField!
    @IBOutlet weak var leachActionTextField: UITextField!
    @IBOutlet weak var masterGraduatingIntervalTextField: UITextField!
    @IBOutlet weak var consecutiveCorrectsTextField: UITextField!
    @IBOutlet weak var startingEaseTextField: UITextField!
    
    var deck: Deck!
    
    weak var delegate: ReviseDeckViewControllerDelegate?
    
    // MARK: - Lifecycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextFields()
    }
    
    // MARK: - Helpers
    
    private func setupTextFields() {
        let newCard = self.deck.newCard
        let lapses = self.deck.lapses
        let master = self.deck.master
        let advanced = self.deck.advanced
        
        learningStepsTextField.text =               "\(newCard.learningStpes)"
        learningGraduatingIntervalTextField.text =  "\(newCard.graduatingInterval)"
        easyIntervalTextField.text =                "\(newCard.easyInterval)"
        relearningStepsTextField.text =             "\(lapses.relearningSteps)"
        minumumIntervalTextField.text =             "\(lapses.minumumInterval)"
        leachThresholdTextField.text =              "\(lapses.leachThreshold)"
        leachActionTextField.text =                 "\(lapses.leachAction)"
        masterGraduatingIntervalTextField.text =    "\(master.graduatingInterval)"
        consecutiveCorrectsTextField.text =         "\(master.consecutiveCorrects)"
        startingEaseTextField.text =                "\(advanced.startingEase)"
    }
    
    @IBAction func saveAction(_ sender: UIButton) {
        guard let deck = self.deck else { return }
        
        let learningSteps = Double(learningStepsTextField.text!)!
        let learningGraduatingInterval = Int(learningGraduatingIntervalTextField.text!)!
        let easyInterval = Int(easyIntervalTextField.text!)!
        let relearningSteps = Double(relearningStepsTextField.text!)!
        let minumumInterval = Int(minumumIntervalTextField.text!)!
        let leachThreshold = Int(leachThresholdTextField.text!)!
        // let leachAction = leachActionTextField.text
        let masterGraduatingInterval = Int(masterGraduatingIntervalTextField.text!)!
        let consecutiveCorrects = Int(consecutiveCorrectsTextField.text!)!
        let startingEase = Double(startingEaseTextField.text!)!
        
        let newCard = Deck.NewCard(graduatingInterval: learningGraduatingInterval, easyInterval: easyInterval, learningStpes: learningSteps)
        let lapses = Deck.Lapses(relearningSteps: relearningSteps, leachThreshold: leachThreshold, minumumInterval: minumumInterval)
        let master = Deck.Master(graduatingInterval: masterGraduatingInterval, consecutiveCorrects: consecutiveCorrects)
        let advanced = Deck.Advanced(startingEase: startingEase, easyBonus: deck.advanced.easyBonus)
        
        let newDeck = Deck(newCard: newCard, lapses: lapses, advanced: advanced, master: master, id: deck.id, name: deck.name, storedCardIds: [])
        
        delegate?.didTapSaveButton(self, revisedDeck: newDeck)
        
        self.dismiss(animated: true)
    }
}
