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
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

    func configureCell(with words: [String]) {
        let stackView = setupStackView()

        for word in words {
            let label = createLabel(with: word)
            stackView.addArrangedSubview(label)
        }

        configureStackViewLayoutPriority(stackView)
    }

    private func setupStackView() -> UIStackView {
        contentView.subviews.forEach { $0.removeFromSuperview() }

        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fill
        stack.alignment = .fill
        stack.spacing = Preference.spacing
        stack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])

        return stack
    }


    private func createLabel(with text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: Preference.fontSize)
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

}
