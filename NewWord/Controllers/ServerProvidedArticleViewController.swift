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
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var originalTextLabel: UILabel!
    @IBOutlet weak var translatedTextLabel: UILabel!
    @IBOutlet var translationContentView: UIView!
    @IBOutlet weak var articlePlayButtonView: ArticlePlayButtonView!
    
    @IBOutlet weak var bottomPanelStackView: UIStackView!
    @IBOutlet weak var selectModeButton: UIButton!
    
    var article: FSArticle?

    private var customTextView: AddTagTextView!
    private let pacticeModelSelectorView: PracticeModeSelectorView = PracticeModeSelectorView()
    private var viewModel: WordSelectorViewControllerViewModel!
    private var player: AudioPlayer = AudioPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.tintColor = UIColor.title
        customTextView.configureProperties()
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    private func setup() {
        setupCumstomTextView()
        setupProperties()
        setupViewModel()
    }

    private func setupProperties() {
        customTextView.layer.zPosition = 0
        translationContentView.layer.zPosition = 1
        imageView.image = article?.fetchedImage
        customTextView.text = article?.text
        
        articlePlayButtonView.playButton.addTarget(self, action: #selector(playArticle), for: .touchUpInside)

        applyBottomToTopFadeGradient(to: imageCoverView, startColor: .background, endColor: .clear)
        
        bottomPanelStackView.addArrangedSubview(pacticeModelSelectorView)

        articlePlayButtonView.addDefaultBorder(cornerRadius: 5)
        pacticeModelSelectorView.addDefaultBorder(cornerRadius: 5)
        pacticeModelSelectorView.delegate = self
        pacticeModelSelectorView.practiceButton.isHidden = true

        player.delegate = self
        
        downloadAudio { isDownloadSuccessful, audioData in
            if isDownloadSuccessful {
                guard let audioData else { return }
                self.player.audioData = audioData
                self.player.setupAudioPlayer()

            } else {
                self.articlePlayButtonView.isHidden = true
            }
        }

        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    private func setupViewModel() {
        viewModel = WordSelectorViewControllerViewModel()
    }

    private func setupCumstomTextView() {
        guard let text = article?.text else { return }

        customTextView = AddTagTextView.createTextView(text)
        customTextView.delegate = self
        customTextView.translatesAutoresizingMaskIntoConstraints = false
        
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(doubleTap(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        customTextView.addGestureRecognizer(doubleTapGesture)
        
        let singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(singleTap(_:)))
        singleTapGesture.numberOfTapsRequired = 1
        singleTapGesture.require(toFail: doubleTapGesture)
        customTextView.addGestureRecognizer(singleTapGesture)

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
    
    @objc func playArticle(_ sender: UIButton) {
        guard let article else { return }
        // guard let ttsSynthesisResult =  article.ttsSynthesisResult else { return }
        
        switch player.state {
        case .notPlayed:
            let audioDataExists = self.player.audioData != nil
            
            if audioDataExists {
                self.player.setupAudioPlayer()
                self.player.playAudioWithMarks(article)
                triggerImpactFeedback()
                
            } else {
                downloadAudio { isDownloadSuccessful, audioData in
                    if isDownloadSuccessful {
                        guard let audioData else { return }
                        self.player.audioData = audioData
                        self.player.setupAudioPlayer()
                        self.player.playAudioWithMarks(article)

                    } else {
                        self.articlePlayButtonView.isHidden = true
                    }
                }
            }
            
        case .playing:
            player.pause()
            triggerImpactFeedback()
            
        case .paused:
            player.playAudioWithMarks(article)
            triggerImpactFeedback()
        }
    }
    
    @objc func singleTap(_ gesture: UITapGestureRecognizer) {
        handleTapGesture(gesture, isWordSelection: true)
    }

    @objc func doubleTap(_ gesture: UITapGestureRecognizer) {
        handleTapGesture(gesture, isWordSelection: false)
    }

    private func handleTapGesture(_ gesture: UITapGestureRecognizer, isWordSelection: Bool) {
        guard !customTextView.isTextSelected() else {
            customTextView.selectedTextRange = nil
            customTextView.configureProperties()
            return
        }

        guard let customTextView = gesture.view as? AddTagTextView else { return }

        var location = gesture.location(in: customTextView)
        location.x -= customTextView.textContainerInset.left
        location.y -= customTextView.textContainerInset.top

        if let characterIndex = customTextView.characterIndex(at: location) {
            handleTextSelection(at: characterIndex, in: customTextView, isWord: isWordSelection)
        }
    }

    private func handleTextSelection(at characterIndex: Int, in textView: AddTagTextView, isWord: Bool) {
        let range = isWord ? textView.wordRange(at: characterIndex) : textView.sentenceRangeContainingCharacter(at: characterIndex)
        
        guard let selectedRange = range else { return }
        
        // 獲取點擊的文字
        let text = (textView.text as NSString).substring(with: selectedRange)
        let textWithoutFFFC = text.removeObjectReplacementCharacter()
        let textType: TextType = isWord ? .word : .sentence
        
        guard !textWithoutFFFC.isBlank else { return }
        
        let translationClosure: ((_ translatedTraditionalText: String) -> ()) = { [weak self] translatedTraditionalText in
            guard let self else { return }
            
            let containsTag = self.viewModel.containsTag(textType: textType, tagType: .listenAndTranslate, range: selectedRange)
            
            self.updateTranslationLabels(originalText: textWithoutFFFC, translatedText: translatedTraditionalText)
            
            textView.removeAllDashedUnderlines()
            textView.addDashedUnderline(in: selectedRange, forWord: isWord)
            
            self.viewModel.selectMode = isWord ? .word : .sentence
            self.viewModel.currentSelectedRange = selectedRange
            
            self.updatePracticeModeSelector(containsTag: containsTag)
            
            UIView.animate(withDuration: 0.3) {
                self.pacticeModelSelectorView.practiceButton.isHidden = false
            }
            
            triggerImpactFeedback()
        }
        
        if viewModel.containsOriginalText(textWithoutFFFC) {
            let translatedText = viewModel.getTranslatedText(textWithoutFFFC)
            
            translationClosure(translatedText!)
            
        } else {
            viewModel.translateEnglishToChinese(textWithoutFFFC) { translatedSimplifiedText in
                let translatedSimplifiedText = translatedSimplifiedText ?? ""
                let translatedTraditionalText = self.viewModel.convertSimplifiedToTraditional(translatedSimplifiedText)
                let translationPair = TranslationPair(originalText: textWithoutFFFC, translatedText: translatedTraditionalText)
                self.viewModel.translationPairs.append(translationPair)
                
                translationClosure(translatedTraditionalText)
            }
        }
    }
    
    private func tag(range: NSRange) {
        // 獲取點擊的文字
        let text = (customTextView.text as NSString).substring(with: range)
        let textWithoutFFFC = text.removeObjectReplacementCharacter()

        guard !text.startsWithObjectReplacementCharacter() else { return }
        guard !viewModel.isWhitespace(text) else { return }
        
        let textType = viewModel.getTextType(from: viewModel.selectMode)
        
        if viewModel.containsTag(textType: textType, tagType: .listenAndTranslate, range: range) {
            viewModel.removeCloze(range)
            
            let adjustmentOffset = -1
            let updatedRange = NSRange(location: range.location-1, length: range.length)

            if !viewModel.hasDuplicateClozeLocations(with: range) {
                customTextView.removeNumberImageView(at: updatedRange.location)
                viewModel.updateTagNSRanges(with: updatedRange, offset: adjustmentOffset)
                viewModel.updateAudioRange(tagPosition: range.location, adjustmentOffset: adjustmentOffset, article: &article)
                viewModel.currentSelectedRange = updatedRange
                customTextView.updateHighlightRangeDuringPlayback(comparedRange: range, adjustmentOffset: adjustmentOffset)
            }

            let coloredText = viewModel.calculateColoredTextHeightFraction()
            let coloredMarks = viewModel.createColoredMarks(coloredText)
            let useRange = viewModel.hasDuplicateClozeLocations(with: range) ? range : updatedRange
            let containsTag = self.viewModel.containsTag(textType: textType, tagType: .listenAndTranslate, range: useRange)

            customTextView.userSelectedColorRanges = coloredText
            customTextView.renewTagImages(coloredMarks)
            customTextView.configureProperties()
            customTextView.removeAllDashedUnderlines()
            customTextView.addDashedUnderline(in: useRange, forWord: self.viewModel.selectMode == .word)
            
            updatePracticeModeSelector(containsTag: containsTag)
            
            triggerImpactFeedback()

            return
        }
        
        let translationClosure: ((_ translatedTraditionalText: String) -> ()) = { [weak self] translatedTraditionalText in
            guard let self else { return }
            
            self.updateTranslationLabels(originalText: textWithoutFFFC, translatedText: translatedTraditionalText)
            self.updateTag(with: range, text: text, hint: translatedTraditionalText)
            self.updateCustomTextView()
            
            if !self.viewModel.hasDuplicateClozeLocations(with: range) {
                let adjustmentOffset = 1
                let updatedRange = NSRange(location: range.location+adjustmentOffset, length: range.length)
                
                self.viewModel.updateAudioRange(tagPosition: range.location, adjustmentOffset: adjustmentOffset, article: &self.article)
                self.viewModel.currentSelectedRange = updatedRange
                self.customTextView.updateHighlightRangeDuringPlayback(comparedRange: range, adjustmentOffset: adjustmentOffset)
                self.customTextView.removeAllDashedUnderlines()
                self.customTextView.addDashedUnderline(in: updatedRange, forWord: self.viewModel.selectMode == .word)
                self.updatePracticeModeSelector(containsTag: self.viewModel.hasDuplicateClozeLocations(with: updatedRange))
                
            } else {
                let textType = self.viewModel.getTextType(from: self.viewModel.selectMode)
                let containsTag = self.viewModel.containsTag(textType: textType, tagType: .listenAndTranslate, range: range)
                self.customTextView.removeAllDashedUnderlines()
                self.customTextView.addDashedUnderline(in: range, forWord: self.viewModel.selectMode == .word)
                self.updatePracticeModeSelector(containsTag: containsTag)
                
            }
            
            triggerImpactFeedback()
        }
        
        
        if viewModel.containsOriginalText(textWithoutFFFC) {
            let translatedText = viewModel.getTranslatedText(textWithoutFFFC)
            
            translationClosure(translatedText!)
            
        } else {
            viewModel.translateEnglishToChinese(textWithoutFFFC) { translatedSimplifiedText in
                let translatedSimplifiedText = translatedSimplifiedText ?? ""
                let translatedTraditionalText = self.viewModel.convertSimplifiedToTraditional(translatedSimplifiedText)
                
                translationClosure(translatedTraditionalText)
            }
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
        self.customTextView.insertNumberImageView(at: range.location, existClozes: self.viewModel.tags, with: String(clozeNumber))

        let offset = 1
        let updateRange = self.viewModel.getUpdatedRange(range: range, offset: offset)
        let textType = self.viewModel.getTextType(text)
        let newCloze = self.viewModel.createNewTag(number: clozeNumber, cloze: text, range: updateRange, textType: textType, hint: hint)
        
        self.viewModel.updateTagNSRanges(with: updateRange, offset: offset)
        self.viewModel.appendCloze(newCloze)
    }

    private func updateCustomTextView() {
        let coloredText = self.viewModel.calculateColoredTextHeightFraction()
        let coloredMarks = self.viewModel.createColoredMarks(coloredText)

        self.customTextView.userSelectedColorRanges = coloredText
        self.customTextView.renewTagImages(coloredMarks)
        self.customTextView.configureProperties()
    }
    
    private func updatePracticeModeSelector(containsTag: Bool) {
        pacticeModelSelectorView.practiceButton.tintColor = viewModel.selectMode == .word ? UIColor.tagGreen : UIColor.tagBlue
        
        let image: UIImage
        
        if containsTag {
            image = UIImage(systemName: "xmark.circle.fill")!
        } else {
            image = UIImage(systemName: "bookmark.circle.fill")!
        }
        
        pacticeModelSelectorView.practiceButton.setImage(image, for: .normal)
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

    private func downloadAudio(completion: ((_ isDownloadSuccessful: Bool, _ audioData: Data?) -> Void)? = nil) {
        guard let article = article, let ttsSynthesisResult = article.ttsSynthesisResult else {
            completion?(false, nil)
            return
        }

        FirestoreManager.shared.downloadAudio(audioId: ttsSynthesisResult.audioId) { isDownloadSuccessful, audioData in
            completion?(isDownloadSuccessful, audioData)
        }
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

    func textViewDidChangeSelection(_ textView: UITextView) {
        textView.selectedRange = NSRange(location: 0, length: 0)
    }
}

// MARK: - AudioPlayerDelegate

extension ServerProvidedArticleViewController: AudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AudioPlayer) {
        articlePlayButtonView.playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        customTextView.highlightRangeDuringPlayback = nil
    }
    
    func audioPlayerDidStartPlaying(_ player: AudioPlayer) {
        articlePlayButtonView.playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
    }
    
    func audioPlayerDidPause(_ player: AudioPlayer) {
        articlePlayButtonView.playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
    }
    
    func audioPlayerDidStop(_ player: AudioPlayer) {
        articlePlayButtonView.playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        customTextView.highlightRangeDuringPlayback = nil
    }
    
    func audioPlayer(_ player: AudioPlayer, didUpdateToMarkName markName: String) {
        guard let article else { return }
        
        let range = viewModel.rangeForMarkName(in: article, markName: markName)
        
        customTextView.highlightRangeDuringPlayback = range
    }
}

extension ServerProvidedArticleViewController: PracticeModeSelectorViewDelegate {
    func practiceModeSelectorViewDidTapPracticeButton(_ selectorView: PracticeModeSelectorView) {
        guard let currentSelectedRange = viewModel.currentSelectedRange else { return }
        
        tag(range: currentSelectedRange)
        
    }
}
