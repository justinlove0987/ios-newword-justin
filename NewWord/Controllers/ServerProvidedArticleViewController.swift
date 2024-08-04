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
    @IBOutlet weak var selectModeButton: UIButton!
    @IBOutlet var translationContentView: UIView!
    
    var inputText: String?

    private var customTextView: AddClozeTextView!
    private var viewModel: WordSelectorViewControllerViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupProperties()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.navigationBar.tintColor = UIColor.title
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

        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    private func setupViewModel() {
        viewModel = WordSelectorViewControllerViewModel()
    }

    private func setupCumstomTextView() {
        inputText = """
Canada's Majestic Forests: A National Treasure

Canada is home to some of the most extensive and diverse forests in the world, covering nearly 40% of its land area. These forests are not just a hallmark of the country's natural beauty but also play a crucial role in its economy, culture, and environment. Spanning from the vast boreal forests to temperate rainforests, Canada’s woodlands are a national treasure that require careful stewardship and appreciation.

The Boreal Forest
The boreal forest, also known as taiga, is Canada's most extensive forest region, covering about 28% of the country's land area. It stretches across the northern part of the country, from Newfoundland and Labrador to the Yukon. This forest type is characterized by its coniferous trees, such as spruce, fir, and pine, which are well adapted to cold climates and poor soil conditions.

The boreal forest is a vital carbon sink, storing vast amounts of carbon and helping to regulate the global climate. It also provides habitat for a wide range of wildlife, including caribou, lynx, and various bird species. The boreal forest is not just a natural wonder but also an essential resource for the timber and pulp and paper industries, which are significant contributors to Canada's economy.

Temperate Rainforests
Canada's west coast, particularly in British Columbia, is home to some of the world's largest temperate rainforests. These rainforests are characterized by high levels of precipitation and mild temperatures, creating ideal conditions for the growth of towering conifers like Douglas fir, western red cedar, and Sitka spruce. Some of these trees can live for over a thousand years, reaching heights of up to 70 meters.

These ancient forests are not only important for their biodiversity but also for their cultural significance to Indigenous peoples. Many Indigenous communities have relied on these forests for sustenance, materials, and spiritual practices for thousands of years. The temperate rainforests are also popular destinations for ecotourism, attracting visitors with their lush, verdant landscapes and abundant wildlife.

Conservation Efforts
Despite their vastness, Canada's forests face significant threats from logging, mining, and climate change. Deforestation and habitat loss can have devastating effects on the ecosystems and species that depend on these forests. In response, there have been significant efforts to promote sustainable forestry practices and establish protected areas.

The Canadian government, along with various Indigenous groups and environmental organizations, has been working to conserve these critical habitats. Initiatives like the Canadian Boreal Forest Agreement aim to balance economic interests with the need to protect biodiversity and ecological integrity. Moreover, there is increasing recognition of the rights and knowledge of Indigenous peoples in forest management, which is vital for ensuring the long-term health and sustainability of these ecosystems.

Conclusion
Canada's forests are a vital part of the country's identity and natural heritage. They provide not only economic benefits but also ecological services that are crucial for maintaining the planet's health. As the world grapples with the challenges of climate change and environmental degradation, the conservation of Canada's forests becomes ever more important. By embracing sustainable practices and respecting Indigenous knowledge and rights, Canada can continue to protect and cherish these majestic forests for future generations.
"""
        guard let inputText else { return }

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))

        customTextView = AddClozeTextView.createTextView(inputText)
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
                    clozeWord(range: wordRange)
                }
            case .sentence:
                if let sentenceRange =  customTextView.sentenceRangeContainingCharacter(at: characterIndex) {
                    clozeWord(range: sentenceRange)
                }
            }
        }
    }

    private func clozeWord(range: NSRange) {
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
                viewModel.updateClozeNSRanges(with: updatedRange, offset: -1)
            }

            let coloredText = viewModel.calculateColoredTextHeightFraction()
            let coloredMarks = viewModel.createColoredMarks(coloredText)

            customTextView.newColorRanges = coloredText
            customTextView.renewTagImages(coloredMarks)
            customTextView.setProperties()

            return
        }

        viewModel.translateEnglishToChinese(textWithoutFFFC) { result in
            switch result {
            case .success(let translatedSimplifiedText):
                let translatedTraditionalText = self.viewModel.convertSimplifiedToTraditional(translatedSimplifiedText)

                self.updateTranslationLabels(originalText: textWithoutFFFC, translatedText: translatedTraditionalText)
                self.updateCloze(with: range, text: text, hint: translatedTraditionalText)
                self.updateCustomTextView()


            case .failure(_):
                self.updateCloze(with: range, text: text, hint: "")
                self.updateCustomTextView()
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

    private func updateCloze(with range: NSRange, text: String, hint: String) {
        let clozeNumber = self.viewModel.getClozeNumber()
        self.customTextView.insertNumberImageView(at: range.location, existClozes: self.viewModel.clozes, with: String(clozeNumber))

        let offset = 1
        let updateRange = self.viewModel.getUpdatedRange(range: range, offset: offset)
        let textType = self.viewModel.getTextType(text)
        let newCloze = self.viewModel.createNewCloze(number: clozeNumber, cloze: text, range: updateRange, textType: textType, hint: hint)

        self.viewModel.updateClozeNSRanges(with: updateRange, offset: offset)
        self.viewModel.appendCloze(newCloze)
    }

    private func updateCustomTextView() {
        let coloredText = self.viewModel.calculateColoredTextHeightFraction()
        let coloredMarks = self.viewModel.createColoredMarks(coloredText)

        self.customTextView.newColorRanges = coloredText
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
