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
    
    var article: CDPracticeArticle?

    private var customTextView: AddTagTextView!
    private let pacticeModelSelectorView: PracticeModeSelectorView = PracticeModeSelectorView()
    private var viewModel: WordSelectorViewControllerViewModel!
    private var player: AudioPlayer = AudioPlayer()
    
    var confirmCallback: (() ->())?
    var waitCallback: (() ->())?

    var isRightBarButtonItemVisible: Bool = true {
           didSet {
               self.navigationItem.rightBarButtonItem?.isEnabled = self.isRightBarButtonItemVisible
               self.navigationItem.rightBarButtonItem?.tintColor = self.isRightBarButtonItemVisible ? nil : UIColor.lightGray.withAlphaComponent(0.8)
           }
       }
    
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
        setupViewModel()
        setupCumstomTextView()
        setupProperties()
    }

    private func setupProperties() {
        customTextView.layer.zPosition = 0
        translationContentView.layer.zPosition = 1
        imageView.image = article?.imageResource?.image

        articlePlayButtonView.playButton.addTarget(self, action: #selector(playArticle), for: .touchUpInside)

        applyBottomToTopFadeGradient(to: imageCoverView, startColor: .background, endColor: .clear)
        
        bottomPanelStackView.addArrangedSubview(pacticeModelSelectorView)

        articlePlayButtonView.addDefaultBorder(cornerRadius: 5)
        pacticeModelSelectorView.addDefaultBorder(cornerRadius: 5)
        pacticeModelSelectorView.delegate = self
        pacticeModelSelectorView.practiceButton.isHidden = true
        
        isRightBarButtonItemVisible = viewModel.hasAnyTag()

        player.delegate = self
        
        setupAudio()
        configureTags()

        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    private func setupViewModel() {
        viewModel = WordSelectorViewControllerViewModel()
        // viewModel.tags = CoreDataManager.shared.getUserGeneratedTags(from: article)
        viewModel.article = article
    }

    private func setupCumstomTextView() {
        guard let text = article?.userGeneratedArticle?.revisedText else { return }

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

    private func setupAudio() {
        guard let article else { return }

        if article.hasAudio {
            self.player.audioData = article.audioResource?.data
            self.player.setupAudioPlayer()

        } else {
            downloadAudio { isDownloadSuccessful, audioData in
                if isDownloadSuccessful {
                    guard let audioData else { return }
                    self.player.audioData = audioData
                    self.player.setupAudioPlayer()

                    article.audioResource?.data = audioData

                    CoreDataManager.shared.save()

                } else {
                    self.articlePlayButtonView.isHidden = true
                }
            }
        }
    }

    // MARK: - Actions
    
    @IBAction func backAction(_ sender: UIBarButtonItem) {
        guard var text = customTextView.text else { return }
        guard let article else { return }
        
        viewModel.showPracticeAlert(presentViewController: self) {
            self.waitCallback?()
            
        } confirmAction: {
            self.confirmCallback?()
        }
    }
    
    @IBAction func settingAction(_ sender: UIBarButtonItem) {
        let controller = PracticeMapViewController.instantiate()
        
        controller.practiceMap = CoreDataManager.shared.getFirstBlueprintMap()
        
        self.navigationController?.pushViewControllerWithCustomTransition(controller)
    }
    
    @objc func playArticle(_ sender: UIButton) {
        guard let article else { return }
        
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
        let textType: ContextType = isWord ? .word : .sentence
        
        guard !textWithoutFFFC.isBlank else { return }
        
        let translationClosure: ((_ translatedTraditionalText: String) -> ()) = { [weak self] translatedTraditionalText in
            guard let self else { return }
            
            let containsTag = self.viewModel.containsTag(textType: textType, range: selectedRange)
            
            self.updateTranslationLabels(originalText: textWithoutFFFC, translatedText: translatedTraditionalText)
            
            textView.removeAllDashedUnderlines()
            textView.updateDashedUnderline(in: selectedRange, forWord: isWord)
            
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

    private func updateTranslationLabels(originalText: String, translatedText: String) {
        self.originalTextLabel.text = originalText
        self.translatedTextLabel.text = translatedText
        self.originalTextLabel.numberOfLines = 0
        self.translatedTextLabel.numberOfLines = 0

        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
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
        guard let article = article, let audioId = article.audioResource?.id else {
            completion?(false, nil)
            return
        }

        FirebaseManager.shared.downloadAudio(audioId: audioId) { isDownloadSuccessful, audioData in
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
    func audioPlayer(_ player: AudioPlayer, didUpdateToRange range: NSRange) {
        customTextView.highlightRangeDuringPlayback = range
    }
    
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
}

extension ServerProvidedArticleViewController: PracticeModeSelectorViewDelegate {
    func practiceModeSelectorViewDidTapPracticeButton(_ selectorView: PracticeModeSelectorView) {
        guard let currentSelectedRange = viewModel.currentSelectedRange else { return }
        
        tag(range: currentSelectedRange)
        
        isRightBarButtonItemVisible = viewModel.hasAnyTag()
    }
}

extension ServerProvidedArticleViewController {

    private func tag(range: NSRange) {
        // 獲取點擊的文字
        let text = (customTextView.text as NSString).substring(with: range)
        let textWithoutFFFC = text.removeObjectReplacementCharacter()

        guard !text.startsWithObjectReplacementCharacter() else { return }
        guard !viewModel.isWhitespace(text) else { return }

        let textType = viewModel.getTextType(from: viewModel.selectMode)

        if viewModel.containsTag(textType: textType, range: range) {
            viewModel.deactivateTag(range)

            let adjustmentOffset = -1
            let updatedRange = NSRange(location: range.location-1, length: range.length)

            if !viewModel.hasDuplicateTagLocations(with: range) {
                customTextView.removeNumberImageView(at: updatedRange.location)
                viewModel.updateTagNSRanges(with: updatedRange, offset: adjustmentOffset)
                viewModel.updateAudioRange(tagPosition: range.location, adjustmentOffset: adjustmentOffset, article: article)
                viewModel.currentSelectedRange = updatedRange
                customTextView.updateHighlightRangeDuringPlayback(comparedRange: range, adjustmentOffset: adjustmentOffset)
            }

            let coloredText = viewModel.calculateColoredTextHeightFraction()
            let coloredMarks = viewModel.createColoredMarks(coloredText)
            let useRange = viewModel.hasDuplicateTagLocations(with: range) ? range : updatedRange
            let containsTag = self.viewModel.containsTag(textType: textType, range: useRange)

            customTextView.userSelectedColorRanges = coloredText
            customTextView.renewTagImages(coloredMarks)
            customTextView.configureProperties()
            customTextView.updateDashedUnderline(in: useRange, forWord: self.viewModel.selectMode == .word)

            updatePracticeModeSelector(containsTag: containsTag)
            
            article?.userGeneratedArticle?.revisedText = customTextView.text

            CoreDataManager.shared.save()
            
            triggerImpactFeedback()

            return
        }

        let translationClosure: ((_ translatedTraditionalText: String) -> ()) = { [weak self] translatedTraditionalText in
            guard let self else { return }
            
            let offset = 1
            let clozeNumber = self.viewModel.getClozeNumber()
            let updateRange = self.viewModel.getUpdatedRange(range: range, offset: offset)
            
            self.updateTranslationLabels(originalText: textWithoutFFFC, translatedText: translatedTraditionalText)
            
            if let tags = article?.userGeneratedArticle?.sortedTaggedContext {
                self.customTextView.insertNumberImageView(at: range.location, existTags: tags, with: String(clozeNumber))
            }
            
            let tag = self.viewModel.activateTag(at: range, text: text, translation: translatedTraditionalText, number: clozeNumber)

            self.viewModel.updateTagNSRanges(with: range, offset: offset)
            self.viewModel.mergePracticeMap(tag)
            self.updateCustomTextView()

            if !self.viewModel.hasDuplicateTagLocations(with: range) {
                let adjustmentOffset = 1
                let updatedRange = NSRange(location: range.location+adjustmentOffset, length: range.length)

                self.viewModel.updateAudioRange(tagPosition: range.location, adjustmentOffset: adjustmentOffset, article: article)
                self.viewModel.currentSelectedRange = updatedRange
                self.customTextView.updateHighlightRangeDuringPlayback(comparedRange: range, adjustmentOffset: adjustmentOffset)
                self.customTextView.updateDashedUnderline(in: updatedRange, forWord: self.viewModel.selectMode == .word)
                self.updatePracticeModeSelector(containsTag: self.viewModel.hasDuplicateTagLocations(with: updatedRange))

            } else {
                let textType = self.viewModel.getTextType(from: self.viewModel.selectMode)
                let containsTag = self.viewModel.containsTag(textType: textType, range: range)
                self.customTextView.updateDashedUnderline(in: range, forWord: self.viewModel.selectMode == .word)
                self.updatePracticeModeSelector(containsTag: containsTag)
            }

            article?.userGeneratedArticle?.revisedText = customTextView.text
            
            CoreDataManager.shared.save()
            
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

    private func configureTags() {
        let coloredText = viewModel.calculateColoredTextHeightFraction()
        let coloredMarks = viewModel.createColoredMarks(coloredText)

        customTextView.userSelectedColorRanges = coloredText
        customTextView.renewTagImages(coloredMarks)
        customTextView.configureProperties()
    }
}
