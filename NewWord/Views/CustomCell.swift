//
//  CustomCell.swift
//  NewWord
//
//  Created by justin on 2024/4/1.
//


import UIKit

protocol CustomCellDelegate: AnyObject {
    func answerCorrect()
    func didCreateTextField(textField: WordTextField)
}

class CustomCell: UITableViewCell {

    var word: Word!

    weak var delegate: CustomCellDelegate?
    
    var textFieldDidChanged: (() -> ())?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
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

    func configureStackViewSubViews(clozeWord: Word, words: [Word], at indexPath: IndexPath) {
        var i = 0
        let stackView = setupStackView()

        while i < words.count {
            let currentWord = words[i]
            let hasNextWord = i+1 < words.count
            let arrangedSubview: UIView
            let isClozeWord = currentWord.text == clozeWord.text

            if hasNextWord {
                let nextWord = words[i+1]

                if nextWord.isPunctuation {
                    let firstView = isClozeWord ? createTextField(with: currentWord) : createLabel(with: currentWord.text)
                    let secondView = createLabel(with: nextWord.text)
                    arrangedSubview = UIStackView(arrangedSubviews: [firstView, secondView])

                    i += 2

                } else {
                    arrangedSubview = isClozeWord ? createTextField(with: currentWord) : createLabel(with: currentWord.text)

                    i += 1
                }

            } else {
                arrangedSubview = createLabel(with: currentWord.text)
                i += 1
            }

            stackView.addArrangedSubview(arrangedSubview)

            configureArrangedSubview(arrangedSubview, for: currentWord, in: stackView)
            configureStackViewLayoutPriority(stackView, words: words)
        }
    }

    private func createTextField(with word: Word) -> UITextField {
        let tf = WordTextField(with: word, frame: .infinite)

        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.backgroundColor = .lightGray
        tf.textAlignment = .center
        tf.font = UIFont.systemFont(ofSize: Preference.fontSize)
        tf.delegate = self
        tf.word = word
        tf.placeholder = word.chinese
        delegate?.didCreateTextField(textField: tf)

        return tf
    }

    private func createLabel(with word: String) -> UILabel {
        let label = UILabel()
        label.text = word
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: Preference.fontSize)
        return label
    }

    private func configureArrangedSubview(_ arrangedSubview: UIView, for currentWord: Word, in stackView: UIStackView) {

        if let arrangedStackView = arrangedSubview as? UIStackView {
            guard arrangedStackView.arrangedSubviews.count > 0 else { return }

            arrangedStackView.axis = .horizontal
            arrangedStackView.distribution = .fill
            arrangedStackView.alignment = .fill

            for subview in arrangedStackView.arrangedSubviews {
                configureArrangedSubview(subview, for: currentWord, in: stackView)
            }
        }

        if let arrangedTextField = arrangedSubview as? UITextField {
            NSLayoutConstraint.activate([
                arrangedTextField.widthAnchor.constraint(equalToConstant: currentWord.bound.width + 8),
                arrangedTextField.heightAnchor.constraint(equalTo: stackView.heightAnchor)
            ])
            return;
        }
    }

    private func configureStackViewLayoutPriority(_ stackView: UIStackView, words: [Word]) {
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

extension CustomCell: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let currentText = textField.text else {
            return true
        }

        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
        let lowercasedNewText = newText.lowercased()

        if let wordTextField = textField as? WordTextField {
            if wordTextField.word.text == lowercasedNewText {
                wordTextField.text = newText
                delegate?.answerCorrect()
                return false
            }
        }

        return true
    }
}

