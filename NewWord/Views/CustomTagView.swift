//
//  CustomTagView.swift
//  NewWord
//
//  Created by justin on 2024/7/14.
//

import UIKit

class CustomTagView: UIView, NibOwnerLoadable {

    @IBOutlet weak var tagStackView: UIStackView!
    @IBOutlet weak var spacingStackView: UIStackView!

    var coloredMark: NewAddClozeViewControllerViewModel.ColoredMark?

    init(coloredMark: NewAddClozeViewControllerViewModel.ColoredMark, lineHeight: CGFloat) {
        self.coloredMark = coloredMark
        super.init(frame: .zero)
        loadNibContent()

        removeSubviews()

        for segment in coloredMark.colorSegments {
            let proportionalHeight = segment.heightFraction*lineHeight*10

            if let tagNumber = segment.tagNumber, segment.isTag {
                let label = TagLabel(customHeight: proportionalHeight)

                label.font = UIFont.systemFont(ofSize: UserDefaultsManager.shared.preferredFontSize * segment.heightFraction,
                                               weight: .medium)

                label.text = "\(tagNumber)"

                label.backgroundColor = segment.color

                if segment.isFirstTag {
                    label.layer.cornerRadius = 5
                    label.layer.maskedCorners = [.layerMinXMinYCorner]
                }

                tagStackView.addArrangedSubview(label)

            } else {
                let label = TagLabel(customHeight: proportionalHeight)
                label.backgroundColor = segment.color
                label.text = ""

                tagStackView.addArrangedSubview(label)
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNibContent()
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadNibContent()
        setup()
    }

    func setup() {

    }

    func configureUI() {
        guard let coloredMark else { return }


    }

    private func removeSubviews() {
        for arrangedSubview in tagStackView.arrangedSubviews {
            arrangedSubview.removeFromSuperview()
        }
    }

}
