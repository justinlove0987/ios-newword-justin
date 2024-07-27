//
//  ListeningClozeView.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/7/26.
//

import UIKit
import AVFoundation
import AVKit

class ListeningClozeView: UIView, NibOwnerLoadable {
    
    @IBOutlet weak var topHalfView: UIView!
    
    @IBOutlet weak var originalTextLabel: UILabel!
    @IBOutlet weak var translatedTextLabel: UILabel!
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    
    private var viewModel: ListeningClozeViewViewModel!
    
    private let playButton = PlayButton()
    
    var synthesizer = AVSpeechSynthesizer()
    
    var currentState: CardStateType = .question {
        didSet {
            updateUI()
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

    
    // MARK: - Helpers
    
    private func setup() {
        setupViewModel()
        setupPlayButton()
        setupLabels()
        setupSynthesizer()
    }
    
    private func setupSynthesizer() {
        synthesizer.delegate = self
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
        translatedTextLabel.text = translatedText
    }
    
    private func setupPlayButton() {
        self.addSubview(playButton)
        
        playButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            playButton.centerYAnchor.constraint(equalTo: topHalfView.centerYAnchor),
            playButton.centerXAnchor.constraint(equalTo: topHalfView.centerXAnchor)
        ])
    }

    private func updateUI() {
        switch currentState {
        case .question:
            playButton.applyOverlayAnimation(duration: 3, color: .border)
            
        case .answer:
            speak(text: originalText, voiceName: "Nicky")
        }
    }
    
    func speak(text: String, voiceName: String? = nil) {
        // 創建 AVSpeechUtterance 實例並設定要講的文字
        let utterance = AVSpeechUtterance(string: text)
        
        // 設定語音的語言（例如，英文）
        if let voiceName = voiceName {
            // 根據語音名稱選擇語音
            let availableVoices = AVSpeechSynthesisVoice.speechVoices()
            if let selectedVoice = availableVoices.first(where: { $0.name == voiceName && $0.language == "en-US" }) {
                utterance.voice = selectedVoice
            } else {
                print("指定的語音名稱 '\(voiceName)' 無法找到。")
                // 默認為未指定語音名稱時的行為
                utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            }
        } else {
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        }
        
        // 設定語速和音調（可根據需要調整）
        utterance.rate = 0.35
        utterance.pitchMultiplier = 1.0
        
        // 開始朗讀文字
        synthesizer.speak(utterance)
    }
    
    func estimatedDuration(for text: String, rate: Double) -> TimeInterval {
        // 設定語速範圍
        let minRate: Double = 0.0
        let maxRate: Double = 1.0
        
        // 設定每分鐘的字數 (假設一個標準語速為 200 WPM)
        let wordsPerMinute: Double = 130
        
        // 計算每秒鐘的字數
        let wordsPerSecond = wordsPerMinute / 60.0
        
        // 計算語速對應的字數每秒
        let wordsPerSecondAtRate = wordsPerSecond * (rate - minRate) / (maxRate - minRate)
        
        // 計算文字的單詞數量
        let wordCount = Double(text.split(separator: " ").count)
        
        // 計算預估持續時間 (秒)
        let duration = wordCount / wordsPerSecond
        
        return duration > 1 ? duration : 1
    }
    
    func listAvailableVoices() -> [AVSpeechSynthesisVoice] {
        return AVSpeechSynthesisVoice.speechVoices()
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
        let duration = estimatedDuration(for: originalText, rate: 0.35)
        playButton.applyOverlayAnimation(duration: duration, color: .border)
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        playButton.imageView.image = UIImage(systemName: "play.fill")
        playButton.overlayViewTrailingConstraint.constant = 80
    }
}
