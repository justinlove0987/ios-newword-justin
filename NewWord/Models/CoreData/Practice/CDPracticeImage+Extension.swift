//
//  CDPracticeImage+CoreDataProperties.swift
//  NewWord
//
//  Created by justin on 2024/9/13.
//
//

import UIKit
import CoreData

@objc(CDPracticeImage)
public class CDPracticeImage: NSManagedObject {

}

extension CDPracticeImage {
    var image: UIImage? {
        guard let data else { return nil }
        return UIImage(data: data)
    }
}
