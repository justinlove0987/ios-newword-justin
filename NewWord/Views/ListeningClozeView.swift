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
    
    var practice: CDPractice?
    
    // MARK: - Lifecycles

    init?(practice: CDPractice) {
        self.practice = practice
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

    deinit {
        print("foo - deinit ListeningClozeView")
        GoogleTTSService.shared.stop()
    }
    
    // MARK: - Helpers
    
    private func setup() {
        setupViewModel()
        setupPlayButton()
        setupLabels()
        
        currentPlaybackState = .playing
    }
    
    private func setupViewModel() {
        viewModel = ListeningClozeViewViewModel()
        viewModel.practice = practice
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
        dummyButton.addTarget(self, action: #selector(playButtonAction), for: .touchUpInside)

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
        guard let practice,
        let userGeneratedContextTag = practice.userGeneratedContent?.userGeneratedContextTag else {
            return
        }
        
        switch currentPlaybackState {
        case .playing:
            if let audio = userGeneratedContextTag.practiceAudio?.data {
                GoogleTTSService.shared.speak(audio)
                
            } else {
                if let word = userGeneratedContextTag.text {
                    GoogleTTSService.shared.download(text: word) { data in
                        userGeneratedContextTag.practiceAudio?.data = data
                        GoogleTTSService.shared.speak(data)
                        CoreDataManager.shared.save()
                    }
                }
            }
            
        case .paused:
            GoogleTTSService.shared.stop()
        }
        
        GoogleTTSService.shared.startCallback = { [weak self] in
            guard let self = self else { return }
            guard let duration = GoogleTTSService.shared.getDuration(userGeneratedContextTag.practiceAudio?.data) else { return }
            self.playButton.applyOverlayAnimation(duration: duration, color: .border)
        }
        
        GoogleTTSService.shared.finishCallback = { [weak self] in
            guard let self = self else { return }
            self.playButton.imageView.image = UIImage(systemName: "play.fill")
            self.playButton.overlayViewTrailingConstraint.constant = 80
            self.currentPlaybackState = .paused
        }
        
        GoogleTTSService.shared.stopCallback = { [weak self] in
            guard let self = self else { return }
            self.playButton.imageView.image = UIImage(systemName: "play.fill")
            self.playButton.overlayViewTrailingConstraint.constant = 80
        }
    }

    @objc func playButtonAction() {
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
