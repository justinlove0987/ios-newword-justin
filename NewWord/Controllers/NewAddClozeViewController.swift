//
//  NewAddClozeViewController.swift
//  NewWord
//
//  Created by justin on 2024/6/30.
//

import UIKit
import NaturalLanguage

class NewAddClozeViewController: UIViewController, StoryboardGenerated {

    static var storyboardName: String = K.Storyboard.main

    @IBOutlet weak var textView: UITextView!

    // MARK: - Lifecycles

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextView()
    }

    // MARK: - Helpers

    private func setupTextView() {
        textView.isEditable = false
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        textView.addGestureRecognizer(tapGesture)
    }

    // MARK: - Actions


    @IBAction func segmentedAction(_ sender: UISegmentedControl) {
    }


    @IBAction func saveAction(_ sender: Any) {
    }

    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        guard let textView = gesture.view as? UITextView else {
            return
        }

        let layoutManager = textView.layoutManager

        var location: CGPoint = gesture.location(in: textView)
        location.x -= textView.textContainerInset.left
        location.y -= textView.textContainerInset.top

        let charIndex = layoutManager.characterIndex(for: location, in: textView.textContainer, fractionOfDistanceBetweenInsertionPoints: nil)

        guard charIndex < textView.textStorage.length else {
            return
        }

        if let wordRange = textView.wordRange(at: charIndex),
           let text = textView.text {
            let word = (text as NSString).substring(with: wordRange)
            print("Tapped word: \(word)")
        }
    }

}

extension UITextView {
    func wordRange(at index: Int) -> NSRange? {
        guard let text = self.text else { return nil }
        let textNSString = text as NSString
        let range = textNSString.rangeOfComposedCharacterSequence(at: index)
        guard let swiftRange = Range(range, in: text) else { return nil }
        let tokenizer = NLTokenizer(unit: .word)
        tokenizer.string = text
        let wordRange = tokenizer.tokenRange(for: swiftRange)
        return NSRange(wordRange, in: text)
    }
}
