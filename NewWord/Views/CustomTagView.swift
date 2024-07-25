//
//  CustomTagView.swift
//  NewWord
//
//  Created by justin on 2024/7/14.
//

import UIKit

class CustomTagView: UIView, NibOwnerLoadable {

    @IBOutlet weak var tagStackView: UIStackView!
    @IBOutlet weak var tagFontSpacingStackView: UIStackView!
    @IBOutlet weak var tagBackSpacingStackView: UIStackView!

    @IBOutlet weak var textFrontSpacingStackView: UIStackView!

    var coloredMark: NewAddClozeViewControllerViewModel.ColoredMark?

    var cornerRadiusCallback: (() -> ())?

    init(coloredMark: NewAddClozeViewControllerViewModel.ColoredMark, lineHeight: CGFloat) {
        self.coloredMark = coloredMark
        super.init(frame: .zero)
        loadNibContent()
        removeSubviews()

        for i in 0..<coloredMark.colorSegments.count {
            let segment = coloredMark.colorSegments[i]
            let proportionalHeight = segment.heightFraction*lineHeight*10

            if let tagNumber = segment.tagNumber, segment.isTag {
                let segmentLabel = TagLabel(customHeight: proportionalHeight)
                segmentLabel.font = UIFont.systemFont(ofSize: UserDefaultsManager.shared.preferredFontSize * segment.heightFraction, weight: .medium)
                segmentLabel.text = "\(tagNumber)"
                segmentLabel.backgroundColor = segment.tagColor

                let tagFrontSpacingView = TagView(customHeight: proportionalHeight)
                tagFrontSpacingView.backgroundColor = segment.tagColor

                let tagBackSpacingView = TagView(customHeight: proportionalHeight)

                if segment.isFirstTagInSegment {
                    cornerRadiusCallback = {
                        tagFrontSpacingView.applyRoundedCorners(corners: [.topLeft], radius: 5)
                    }

                    if i - 1 > 0 {
                        tagBackSpacingView.backgroundColor = coloredMark.colorSegments[i-1].contentColor
                    }
                }

                let textFrontSpacingView = TagView(customHeight: proportionalHeight)
                textFrontSpacingView.backgroundColor = segment.contentColor

                tagStackView.addArrangedSubview(segmentLabel)
                tagFontSpacingStackView.addArrangedSubview(tagFrontSpacingView)
                tagBackSpacingStackView.addArrangedSubview(tagBackSpacingView)
                textFrontSpacingStackView.addArrangedSubview(textFrontSpacingView)


            } else {
                let label = TagLabel(customHeight: proportionalHeight)
                label.backgroundColor = segment.contentColor
                label.text = ""
                
                let tagFrontSpacingView = TagView(customHeight: proportionalHeight)
                tagFrontSpacingView.backgroundColor = segment.contentColor

                let tagBackSpacingView = TagView(customHeight: proportionalHeight)
                tagBackSpacingView.backgroundColor = segment.contentColor

                let textFrontSpacingView = TagView(customHeight: proportionalHeight)
                textFrontSpacingView.backgroundColor = segment.contentColor

                tagStackView.addArrangedSubview(label)
                tagFontSpacingStackView.addArrangedSubview(tagFrontSpacingView)
                tagBackSpacingStackView.addArrangedSubview(tagBackSpacingView)
                textFrontSpacingStackView.addArrangedSubview(textFrontSpacingView)

            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNibContent()

    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadNibContent()
    }

    private func removeSubviews() {
        for subview in tagStackView.arrangedSubviews {
            subview.removeFromSuperview()
        }

        for subview in tagFontSpacingStackView.arrangedSubviews {
            subview.removeFromSuperview()
        }
    }

    func addCornerRadius(view: UIView, corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        view.layer.mask = mask
    }

}
