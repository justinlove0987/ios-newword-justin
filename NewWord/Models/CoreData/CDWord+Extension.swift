//
//  CDWord+Extension.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/5/31.
//

import UIKit
import CoreData


@objc(CDWord)
public class CDWord: NSManagedObject {

}


extension CDWord {
    var isPunctuation: Bool {
        let punctuationRegex = try! NSRegularExpression(pattern: "^\\p{P}*$", options: [])
        return punctuationRegex.firstMatch(in: text!, options: [], range: NSRange(location: 0, length: text!.utf16.count)) != nil
    }

    var size: CGSize {
        return text!.size(withAttributes: [.font: UIFont.systemFont(ofSize: Preference.fontSize)])
    }

    var chineseSize: CGSize {
        return chinese!.size(withAttributes: [.font: UIFont.systemFont(ofSize: Preference.fontSize)])
    }
}
