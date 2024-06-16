//
//  ContextCell.swift
//  NewWord
//
//  Created by justin on 2024/6/14.
//

import UIKit

class ContextCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureCell(with sentence: [String]) {
        let hasWord =  sentence.count > 0

        guard hasWord else {
            let label = ContextStackView(text: "", frame: .zero)
            let verticalStackView = createVerticalStackView()
            verticalStackView.addArrangedSubview(label)
            return
        }

        let verticalStackView = createVerticalStackView()

        let maximumWidth: CGFloat = 375

        var currentTotalWidth: CGFloat = 0.0
        var wordIndex = 0
        var horizontalStackView = createHorizontalStackView()

        while wordIndex < sentence.count {
            let currentWord = sentence[wordIndex]
            let size = getTextSize(currentWord)
            let width = size.width

            if currentTotalWidth + width + Preference.spacing > maximumWidth {
                currentTotalWidth = 0
                let dummyView = UIView()
                horizontalStackView.addArrangedSubview(dummyView)
                verticalStackView.addArrangedSubview(horizontalStackView)
                horizontalStackView = createHorizontalStackView()

            } else {
                currentTotalWidth += width
                currentTotalWidth += Preference.spacing
                wordIndex += 1

                let stackView = ContextStackView(text: currentWord, frame: .zero)
                horizontalStackView.addArrangedSubview(stackView)
            }
        }
        
        let hasSubviews = horizontalStackView.arrangedSubviews.count > 0

        if hasSubviews {
            let dummyView = UIView()
            horizontalStackView.addArrangedSubview(dummyView)
            verticalStackView.addArrangedSubview(horizontalStackView)
        }

        configureStackViewLayoutPriority(verticalStackView)

    }

    private func createVerticalStackView() -> UIStackView {
        contentView.subviews.forEach { $0.removeFromSuperview() }

        let verticalStackView = UIStackView()
        verticalStackView.axis = .vertical
        verticalStackView.distribution = .fillEqually
        verticalStackView.alignment = .fill
        verticalStackView.spacing = 0
        verticalStackView.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(verticalStackView)

        NSLayoutConstraint.activate([
            verticalStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            verticalStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            verticalStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            verticalStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])

        return verticalStackView
    }

    private func createHorizontalStackView() -> UIStackView {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fill
        stack.alignment = .fill
        stack.spacing = Preference.spacing
        stack.translatesAutoresizingMaskIntoConstraints = false

        return stack
    }

    private func createLabel(with text: String) -> UILabel {
        let label = ContextLabel()
        label.text = text
        return label
    }

    private func configureStackViewLayoutPriority(_ stackView: UIStackView) {
        var priority = 1000
        let arrangedSubviews = stackView.arrangedSubviews

        for subview in arrangedSubviews {
            if let subStackView = subview as? UIStackView {
                for subview in subStackView.arrangedSubviews {
                    subview.setContentHuggingPriority(UILayoutPriority(Float(priority)), for: .horizontal)
                    priority -= 1
                }
            } else {
                subview.setContentHuggingPriority(UILayoutPriority(Float(priority)), for: .horizontal)
                priority -= 1
            }
        }
    }

    func getTextSize(_ text: String) -> CGSize {
        return text.size(withAttributes: [.font: UIFont.systemFont(ofSize: Preference.fontSize)])
    }


    func isPunctuation(_ text: String) -> Bool {
        let punctuationRegex = try! NSRegularExpression(pattern: "^\\p{P}*$", options: [])
        return punctuationRegex.firstMatch(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count)) != nil
    }

}
