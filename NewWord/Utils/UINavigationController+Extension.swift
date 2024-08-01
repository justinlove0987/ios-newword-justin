//
//  UINavigationController+Extension.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/8/1.
//

import UIKit

extension UINavigationController {
    func pushViewControllerWithCustomTransition(_ controller: UIViewController) {
        controller.modalTransitionStyle = .crossDissolve
        controller.modalPresentationStyle = .fullScreen
        controller.hidesBottomBarWhenPushed = true
        controller.view.layoutIfNeeded()
        
        self.pushViewController(controller, animated: true)
    }
}
