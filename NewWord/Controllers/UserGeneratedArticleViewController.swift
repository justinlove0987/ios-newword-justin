//
//  NewAddClozeViewController.swift
//  NewWord
//
//  Created by justin on 2024/6/30.
//

import UIKit
import NaturalLanguage

struct NewAddCloze {
    enum TextType {
        case word
        case sentence
        case article
    }
    
    let number: Int
    let text: String
    var range: NSRange
    let tagColor: UIColor
    let contentColor: UIColor
    var textType: TextType = .word
    let hint: String
    
    func getTagIndex(in text: String) -> String.Index? {
        let location = range.location - 1

        if let stringIndex = text.index(text.startIndex, offsetBy: location, limitedBy: text.endIndex) {
            return stringIndex
        }
        
        return nil
    }
}

class UserGeneratedArticleViewController: UIViewController, StoryboardGenerated {
    
    // MARK: - Properties
    
    static var storyboardName: String = K.Storyboard.main
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var originalTextLabel: UILabel!
    @IBOutlet weak var translatedTextLabel: UILabel!
    @IBOutlet weak var selectModeButton: UIButton!
    @IBOutlet var translationContentView: UIView!
    @IBOutlet weak var contextContentView: UIView!
    
    var inputText: String?
    
    private var customTextView: AddClozeTextView!
    private var viewModel: WordSelectorViewControllerViewModel!
    
    // MARK: - Lifecycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupProperties()
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    // MARK: - Helpers
    
    private func setup() {
        setupProperties()
        setupViewModel()
        setupCumstomTextView()
    }
    
    private func setupProperties() {
        translationContentView.addDefaultBorder(maskedCorners: [.layerMinXMinYCorner, .layerMaxXMinYCorner])
        contextContentView.addDefaultBorder(maskedCorners: [.layerMinXMaxYCorner, .layerMaxXMaxYCorner])

        contextContentView.layer.zPosition = 0
        translationContentView.layer.zPosition = 1
        
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    private func setupViewModel() {
        viewModel = WordSelectorViewControllerViewModel()
    }
    
    private func setupCumstomTextView() {
        guard let inputText else { return }

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))

        customTextView = AddClozeTextView.createTextView(inputText)
        customTextView.delegate = self
        customTextView.translatesAutoresizingMaskIntoConstraints = false
        customTextView.addGestureRecognizer(tapGesture)

        self.view.addSubview(customTextView)
        
        NSLayoutConstraint.activate([
            customTextView.topAnchor.constraint(equalTo: contextContentView.topAnchor, constant: 20),
            customTextView.bottomAnchor.constraint(equalTo: contextContentView.bottomAnchor, constant: -20),
            customTextView.leadingAnchor.constraint(equalTo: contextContentView.leadingAnchor, constant: 20),
            customTextView.trailingAnchor.constraint(equalTo: contextContentView.trailingAnchor, constant: -20),
        ])
    }
    
    // MARK: - Actions
    
    @IBAction func previousAction(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
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

    //    @IBAction func settingAction(_ sender: UIButton) {
    //        let controller = TagSettingViewController.instantiate()
    //        navigationController?.present(controller, animated: true)
    //    }

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

    // MARK: - Helpers

    private func clozeWord(range: NSRange) {
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
            }

            let coloredText = viewModel.calculateColoredTextHeightFraction()
            let coloredMarks = viewModel.createColoredMarks(coloredText)

            customTextView.userSelectedColorRanges = coloredText
            customTextView.renewTagImages(coloredMarks)
            customTextView.setProperties()

            return
        }

//        viewModel.translateEnglishToChinese(textWithoutFFFC) { result in
//            switch result {
//            case .success(let translatedSimplifiedText):
//                let translatedTraditionalText = self.viewModel.convertSimplifiedToTraditional(translatedSimplifiedText)
//
//                self.updateTranslationLabels(originalText: textWithoutFFFC, translatedText: translatedTraditionalText)
//                self.updateCloze(with: range, text: text, hint: translatedTraditionalText)
//                self.updateCustomTextView()
//
//            case .failure(_):
//                self.updateCloze(with: range, text: text, hint: "")
//                self.updateCustomTextView()
//            }
//        }
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

        self.viewModel.updateTagNSRanges(with: updateRange, offset: offset)
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
}

extension UserGeneratedArticleViewController: UITextViewDelegate {
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
