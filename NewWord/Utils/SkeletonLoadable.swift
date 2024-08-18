//
//  SkeletonLoadable.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/8/18.
//

import UIKit


protocol SkeletonLoadable {}

extension SkeletonLoadable {

    func makeAnimationGroup(previousGroup: CAAnimationGroup? = nil) -> CAAnimationGroup {
        let animDuration: CFTimeInterval = 1.5

        let anim1 = CABasicAnimation(keyPath: #keyPath(CAGradientLayer.colors))
        anim1.fromValue = UIColor.gradientLightGrey.cgColor
        anim1.toValue = UIColor.gradientDarkGrey.cgColor
        anim1.duration = animDuration
        anim1.beginTime = 0.0

        let anim2 = CABasicAnimation(keyPath: #keyPath(CAGradientLayer.colors))
        anim2.fromValue = UIColor.gradientDarkGrey.cgColor
        anim2.toValue = UIColor.gradientLightGrey.cgColor
        anim2.duration = animDuration
        anim2.beginTime = anim1.beginTime + anim1.duration

        let group = CAAnimationGroup()
        group.animations = [anim1, anim2]
        group.repeatCount = .greatestFiniteMagnitude // infinite
        group.duration = anim2.beginTime + anim2.duration
        group.isRemovedOnCompletion = false

        if let previousGroup = previousGroup {
            // Offset groups by 0.33 seconds for effect
            group.beginTime = previousGroup.beginTime + 0.33
        }

        return group
    }

    func testAnimationGroup(previousGroup: CAAnimationGroup? = nil) -> CAAnimationGroup {
        let animDuration: CFTimeInterval = 1.5

        let anim1 = CABasicAnimation(keyPath: "colors")
        anim1.duration = animDuration
        anim1.fromValue = [UIColor.gradientDarkGrey, UIColor.gradientLightGrey]
        anim1.toValue = [UIColor.gradientLightGrey, UIColor.gradientDarkGrey]
        anim1.beginTime = 0.0

        let anim2 = CABasicAnimation(keyPath: "colors")
        anim2.duration = animDuration
        anim2.fromValue = [UIColor.gradientLightGrey, UIColor.gradientDarkGrey]
        anim2.toValue = [UIColor.gradientDarkGrey, UIColor.gradientLightGrey]
        anim2.beginTime = anim1.beginTime + anim1.duration

        let group = CAAnimationGroup()
        group.animations = [anim1, anim2]
        group.repeatCount = .greatestFiniteMagnitude // infinite
        group.duration = anim2.beginTime + anim2.duration
        group.isRemovedOnCompletion = false

        if let previousGroup = previousGroup {
            // Offset groups by 0.33 seconds for effect
            group.beginTime = previousGroup.beginTime + 0.33
        }

        return group
    }

}

extension UIColor {

    static var gradientDarkGrey: UIColor {
        return .black
        // return UIColor(red: 239 / 255.0, green: 241 / 255.0, blue: 241 / 255.0, alpha: 1)
    }

    static var gradientLightGrey: UIColor {
        return .white
//        return UIColor(red: 201 / 255.0, green: 201 / 255.0, blue: 201 / 255.0, alpha: 1)
    }

}
