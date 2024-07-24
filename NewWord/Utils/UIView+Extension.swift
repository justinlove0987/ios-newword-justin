//
//  UIView+Extension.swift
//  NewWord
//
//  Created by justin on 2024/7/10.
//

import UIKit

extension UIView {

    func asImage() -> UIImage {
        if #available(iOS 10.0, *) {
            let renderer = UIGraphicsImageRenderer(bounds: bounds)
            return renderer.image { rendererContext in
                layer.render(in: rendererContext.cgContext)
            }
        } else {
            UIGraphicsBeginImageContext(self.frame.size)
            self.layer.render(in:UIGraphicsGetCurrentContext()!)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return UIImage(cgImage: image!.cgImage!)
        }
    }
    
    func addDefaultBorder() {
        self.layer.borderColor = UIColor.border.cgColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 15
        self.layer.masksToBounds = true
    }
}
