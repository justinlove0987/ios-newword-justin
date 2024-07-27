//
//  ListeningClozeView.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/7/26.
//

import UIKit
import AVKit

class ListeningClozeView: UIView, NibOwnerLoadable {

    enum PlaybackState {
        case playing
        case paused
    }

    @IBOutlet weak var topHalfView: UIView!
    @IBOutlet weak var originalTextLabel: UILabel!
    @IBOutlet weak var translatedTextLabel: UILabel!
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!

    private var dummyButton = UIButton()
    private var viewModel: ListeningClozeViewViewModel!
    private var playButton: PlayButton!

    var currentState: CardStateType = .question {
        didSet {
            updateUI()
        }
    }

    private var currentPlaybackState: PlaybackState = .paused {
        didSet {
            updatePlayButtonUI()
        }
    }

    var originalText: String = ""
    var translatedText: String = ""
    
    var card: CDCard?
    
    // MARK: - Lifecycles

    init?(card: CDCard) {
        self.card = card
        super.init(frame: .zero)
        loadNibContent()
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNibContent()
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadNibContent()
        setup()
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        currentPlaybackState = .playing
    }

    deinit {
        print("foo - deinit ListeningClozeView")
        viewModel.stopSpeaking()
    }
    
    // MARK: - Helpers
    
    private func setup() {
        setupViewModel()
        setupPlayButton()
        setupLabels()
        setupSynthesizer()
    }
    
    private func setupSynthesizer() {
        viewModel.synthesizer.delegate = self
    }
    
    private func setupViewModel() {
        viewModel = ListeningClozeViewViewModel()
        viewModel.card = card
    }
    
    private func setupLabels() {
        guard let originalText = viewModel.getOriginalText(),
              let translatedText = viewModel.getTranslatedText() else {
                return
        }
        
        self.originalText = originalText
        self.translatedText = translatedText


        if !originalText.isSentence() {
            originalTextLabel.textAlignment = .center
            translatedTextLabel.textAlignment = .center
            widthConstraint.isActive = false
        }
        
        originalTextLabel.text = originalText
        originalTextLabel.isHidden = true
        translatedTextLabel.text = translatedText
        translatedTextLabel.isHidden = true
    }
    
    private func setupPlayButton() {
        playButton = PlayButton()

        self.addSubview(playButton)
        
        playButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            playButton.centerYAnchor.constraint(equalTo: topHalfView.centerYAnchor),
            playButton.centerXAnchor.constraint(equalTo: topHalfView.centerXAnchor)
        ])

        addSubview(dummyButton)

        dummyButton.translatesAutoresizingMaskIntoConstraints = false
        dummyButton.backgroundColor = .clear
        dummyButton.addTarget(self, action: #selector(dummyButtonAction), for: .touchUpInside)

        NSLayoutConstraint.activate([
            dummyButton.centerYAnchor.constraint(equalTo: topHalfView.centerYAnchor),
            dummyButton.centerXAnchor.constraint(equalTo: topHalfView.centerXAnchor),
            dummyButton.heightAnchor.constraint(equalTo: dummyButton.widthAnchor, multiplier: 0.618),
            dummyButton.widthAnchor.constraint(equalToConstant: 80)
        ])
    }

    private func updateUI() {
        switch currentState {
        case .question:
            playButton.applyOverlayAnimation(duration: 3, color: .border)
            
        case .answer:
            translatedTextLabel.isHidden = false
            originalTextLabel.isHidden = false
        }
    }

    private func updatePlayButtonUI() {
        switch currentPlaybackState {
        case .playing:
            viewModel.speak(text: originalText, voiceName: "")
        case .paused:
            viewModel.stopSpeaking()
        }
    }

    @objc func dummyButtonAction() {
        switch self.currentPlaybackState {
        case .playing:
            self.currentPlaybackState = .paused
        case .paused:
            self.currentPlaybackState = .playing
        }
    }

}

// MARK: - ShowCardsSubviewDelegate

extension ListeningClozeView: ShowCardsSubviewDelegate {
 
    enum CardStateType: Int, CaseIterable {
        case question
        case answer
    }
}

// MARK: - AVSpeechSynthesizerDelegate

extension ListeningClozeView: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        let duration = viewModel.estimatedDuration(for: originalText, rate: 0.35)
        playButton.applyOverlayAnimation(duration: duration, color: .border)
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        playButton.imageView.image = UIImage(systemName: "play.fill")
        playButton.overlayViewTrailingConstraint.constant = 80
        currentPlaybackState = .paused
    }
}
