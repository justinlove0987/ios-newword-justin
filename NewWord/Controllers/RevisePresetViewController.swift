//
//  ReviseDeckViewController.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/5/6.
//

import UIKit

protocol RevisePresetViewControllerDelegate: AnyObject {
    func didTapSaveButton(_ controller: RevisePresetViewController)
}

class RevisePresetViewController: UIViewController, StoryboardGenerated {
    
    static var storyboardName: String = K.Storyboard.main
    
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
    
    var deck: CDDeck!

    weak var delegate: RevisePresetViewControllerDelegate?
    
    // MARK: - Lifecycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextFields()
    }
    
    // MARK: - Helpers
    
    private func setupTextFields() {
        guard let preset = self.deck.preset else { return }
        let newCard = preset.newCard!
        let lapses = preset.lapses!
        let master = preset.master!
        let advanced = preset.advanced!

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

        
        let newCard = CoreDataManager.shared.addNewCard(graduatingInterval: learningGraduatingInterval, easyInterval: easyInterval, learningStpes: learningSteps)

        let lapses = CoreDataManager.shared.addLapses(relearningSteps: relearningSteps, leachThreshold: leachThreshold, minumumInterval: minumumInterval)
        
        
        let master = CoreDataManager.shared.addMaster(graduatingInterval: masterGraduatingInterval, consecutiveCorrects: consecutiveCorrects)
        
        let advanced = CoreDataManager.shared.addAdvanced(startingEase: startingEase, easyBonus: 1.3)
        
        deck.preset?.newCard = newCard
        deck.preset?.lapses = lapses
        deck.preset?.master = master
        deck.preset?.advanced = advanced
        
        delegate?.didTapSaveButton(self)
        
        self.dismiss(animated: true)
    }
}
