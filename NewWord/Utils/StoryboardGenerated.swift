//
//  StoryboardGenerated.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/5/30.
//

import UIKit

protocol StoryboardGenerated: AnyObject {
    static var storyboardName: String { get }
    static func instantiate() -> Self
}

extension StoryboardGenerated where Self: UIViewController {
    static func instantiate() -> Self {
        let identifier = String(describing: self)
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: identifier) as! Self
        return controller
    }
}
