//
//  ContextStackView.swift
//  NewWord
//
//  Created by justin on 2024/6/15.
//

import UIKit

class ContextStackView: UIStackView {
    
    typealias ClozeWord = AddClozeViewControllerViewModel.ClozeWord

    var text: String

    init(cloze: ClozeWord, frame: CGRect) {
        self.text = cloze.text
        super.init(frame: frame)

        axis = .horizontal
        distribution = .fill
        alignment = .leading
        spacing = 0

        let hasText = text.count > 0

        if hasText {
            let splits = splitTextIntoWordsAndPunctuation(text: cloze.text)

            for split in splits {
                let label = ContextLabel()
                label.clozeWord = cloze
                label.isSelected = cloze.selected

                if isPunctuation(split) {
                    label.labelType = .punctuation

                } else {
                    label.labelType = .word
                }

                label.text = split
                addArrangedSubview(label)
            }
        } else {
            let label = ContextLabel()
            label.labelType = .newline
            label.text = " "
            addArrangedSubview(label)
        }
    }

    override init(frame: CGRect) {
        self.text = ""
        super.init(frame: frame)
    }

    required init(coder: NSCoder) {
        self.text = ""
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }

    func isPunctuation(_ text: String) -> Bool {
        let punctuationRegex = try! NSRegularExpression(pattern: "^\\p{P}*$", options: [])
        return punctuationRegex.firstMatch(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count)) != nil
    }

    func splitTextIntoWordsAndPunctuation(text: String) -> [String] {
        let pattern = "[\\w']+|[.,!?;:()\"'\\[\\]—-]"
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        
        let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count))
        
        var result: [String] = []
        
        for match in matches {
            if let range = Range(match.range, in: text) {
                result.append(String(text[range]))
            }
        }
        
        return result
    }

}
