//
//  WordSelectorViewController.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/8/1.
//

import UIKit

class ServerProvidedArticleViewController: UIViewController, StoryboardGenerated {

    // MARK: - Properties

    static var storyboardName: String = K.Storyboard.main

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageCoverView: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var originalTextLabel: UILabel!
    @IBOutlet weak var translatedTextLabel: UILabel!
    @IBOutlet weak var selectModeButton: UIButton!
    @IBOutlet var translationContentView: UIView!
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var playAudioView: UIView!
    
    var article: FSArticle?

    private var customTextView: AddClozeTextView!
    private var viewModel: WordSelectorViewControllerViewModel!
    
    private var player: AudioPlayer = AudioPlayer()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.tintColor = UIColor.title
        customTextView.setProperties()
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    private func setup() {
        setupCumstomTextView()
        setupProperties()
        setupViewModel()

        applyBottomToTopFadeGradient(to: imageCoverView, startColor: .background, endColor: .clear)
    }

    private func setupProperties() {
        customTextView.layer.zPosition = 0
        translationContentView.layer.zPosition = 1
        imageView.image = article?.image
        customTextView.text = article?.text
        
        playAudioView.addDefaultBorder(cornerRadius: 5)
        player.delegate = self

        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    private func setupViewModel() {
        viewModel = WordSelectorViewControllerViewModel()
    }

    private func setupCumstomTextView() {
        guard let text = article?.content else { return }

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))

        customTextView = AddClozeTextView.createTextView(text)
        customTextView.delegate = self
        customTextView.translatesAutoresizingMaskIntoConstraints = false
        customTextView.addGestureRecognizer(tapGesture)

        self.view.addSubview(customTextView)

        NSLayoutConstraint.activate([
            customTextView.topAnchor.constraint(equalTo: textView.topAnchor),
            customTextView.bottomAnchor.constraint(equalTo: textView.bottomAnchor),
            customTextView.leadingAnchor.constraint(equalTo: textView.leadingAnchor),
            customTextView.trailingAnchor.constraint(equalTo: textView.trailingAnchor)
        ])
    }

    // MARK: - Actions


    @IBAction func confirmAction(_ sender: UIBarButtonItem) {
        guard var text = customTextView.text else { return }

        text = viewModel.removeAllTags(in: text)
        viewModel.saveCloze(text)

        navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func selectModeAction(_ sender: UIButton) {
        viewModel.changeSelectMode()
        selectModeButton.setTitle(viewModel.selectMode.title, for: .normal)
    }
    
    @IBAction func playButtonAction(_ sender: UIButton) {
        guard let article else { return }
        guard let ttsSynthesisResult =  article.ttsSynthesisResult else { return }
        
        switch player.state {
        case .notPlayed:
            FirestoreManager.shared.downloadAudio(audioId: ttsSynthesisResult.audioId) { isDownloadSuccessful, audioData in
                guard let audioData else { return }
                
                self.player.audioData = audioData
                self.player.playAudioWithMarks(article)
            }
        case .playing:
            player.pause()
            
        case .paused:
            player.play()
        }
        
        
    }
    
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        guard !customTextView.isTextSelected() else {
            customTextView.selectedTextRange = nil
            customTextView.setProperties()
            return
        }

        guard let customTextView = gesture.view as? AddClozeTextView else { return }

        var location = gesture.location(in: customTextView)
        location.x -= customTextView.textContainerInset.left
        location.y -= customTextView.textContainerInset.top

        if let characterIndex = customTextView.characterIndex(at: location) {
            switch viewModel.selectMode {
            case .word:
                if let wordRange = customTextView.wordRange(at: characterIndex) {
                    tagWord(range: wordRange)
                }
            case .sentence:
                if let sentenceRange =  customTextView.sentenceRangeContainingCharacter(at: characterIndex) {
                    tagWord(range: sentenceRange)
                }
            }
        }
    }

    private func tagWord(range: NSRange) {
        // 獲取點擊的文字
        let text = (customTextView.text as NSString).substring(with: range)
        let textWithoutFFFC = text.removeObjectReplacementCharacter()

        guard !text.startsWithObjectReplacementCharacter() else { return }
        guard !viewModel.isWhitespace(text) else { return }
        guard !viewModel.containsCloze(range) else {
            viewModel.removeCloze(range)

            if !viewModel.hasDuplicateClozeLocations(with: range) {
                let updatedRange = NSRange(location: range.location-1, length: range.length)
                customTextView.removeNumberImageView(at: updatedRange.location)
                viewModel.updateTagNSRanges(with: updatedRange, offset: -1)
                viewModel.updateAudioRange(tagPosition: range.location, adjustmentOffset: -1, article: &article)
            }

            let coloredText = viewModel.calculateColoredTextHeightFraction()
            let coloredMarks = viewModel.createColoredMarks(coloredText)

            customTextView.userSelectedColorRanges = coloredText
            customTextView.renewTagImages(coloredMarks)
            customTextView.setProperties()

            return
        }

        viewModel.translateEnglishToChinese(textWithoutFFFC) { translatedSimplifiedText in
            let translatedSimplifiedText = translatedSimplifiedText ?? ""
            let translatedTraditionalText = self.viewModel.convertSimplifiedToTraditional(translatedSimplifiedText)

            self.updateTranslationLabels(originalText: textWithoutFFFC, translatedText: translatedTraditionalText)
            self.updateTag(with: range, text: text, hint: translatedTraditionalText)
            self.updateCustomTextView()
        }
    }

    private func updateTranslationLabels(originalText: String, translatedText: String) {
        self.originalTextLabel.text = originalText
        self.translatedTextLabel.text = translatedText
        self.originalTextLabel.numberOfLines = 0
        self.translatedTextLabel.numberOfLines = 0

        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }

    private func updateTag(with range: NSRange, text: String, hint: String) {
        let clozeNumber = self.viewModel.getClozeNumber()
        self.customTextView.insertNumberImageView(at: range.location, existClozes: self.viewModel.clozes, with: String(clozeNumber))

        let offset = 1
        let updateRange = self.viewModel.getUpdatedRange(range: range, offset: offset)
        let textType = self.viewModel.getTextType(text)
        let newCloze = self.viewModel.createNewCloze(number: clozeNumber, cloze: text, range: updateRange, textType: textType, hint: hint)

        self.viewModel.updateTagNSRanges(with: updateRange, offset: offset)
        self.viewModel.updateAudioRange(tagPosition: range.location, adjustmentOffset: offset, article: &article)
        self.viewModel.appendCloze(newCloze)
    }

    private func updateCustomTextView() {
        let coloredText = self.viewModel.calculateColoredTextHeightFraction()
        let coloredMarks = self.viewModel.createColoredMarks(coloredText)

        self.customTextView.userSelectedColorRanges = coloredText
        self.customTextView.renewTagImages(coloredMarks)
        self.customTextView.setProperties()
    }

    @objc func appDidBecomeActive() {
        updateCustomTextView()
    }

    func applyBottomToTopFadeGradient(to view: UIView, startColor: UIColor, endColor: UIColor = .clear) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds

        // 設定漸層的顏色，由開始的顏色漸變到透明
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]

        // 設定漸層的起點和終點，這裡設定為從下至上
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.7)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.0)

        view.layer.insertSublayer(gradientLayer, at: 0)
    }
}

// MARK: - UITextViewDelegate

extension ServerProvidedArticleViewController: UITextViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView == customTextView {
            self.originalTextLabel.numberOfLines = 1
            self.translatedTextLabel.numberOfLines = 1

            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }
}

extension ServerProvidedArticleViewController: AudioPlayerDelegate {
    func audioPlayerDidStartPlaying(_ player: AudioPlayer) {
        playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
    }
    
    func audioPlayerDidPause(_ player: AudioPlayer) {
        playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
    }
    
    func audioPlayerDidStop(_ player: AudioPlayer) {
        
    }
    
    func audioPlayer(_ player: AudioPlayer, didUpdateToMarkName markName: String) {
        guard let article else { return }
        
        let range = viewModel.rangeForMarkName(in: article, markName: markName)
        
        customTextView.highlightRangeDuringPlayback = range
    }
}
