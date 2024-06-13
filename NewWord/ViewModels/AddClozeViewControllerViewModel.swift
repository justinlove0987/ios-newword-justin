//
//  AddClozeViewControllerViewModel.swift
//  NewWord
//
//  Created by justin on 2024/6/14.
//

import UIKit

struct AddClozeViewControllerViewModel {

    var context: String
    let contextSize: CGSize

    func getRows() -> [[String]] {

        var result: [[String]] = []
        
        let words = processText(context)

        let maximumWidth = contextSize.width
        var row: [String] = []
        var currentTotalWidth: CGFloat = 0.0
        var i = 0

        while i < words.count {
            let currentWord = words[i]
            let size = getTextSize(currentWord)
            let width = size.width

            if currentWord == "\n" {
                result.append(row)
                result.append([""])
                currentTotalWidth = 0
                row = []
                i += 1
                continue
            }

            if currentTotalWidth + width + Preference.spacing > maximumWidth {
                result.append(row)
                currentTotalWidth = 0
                row = []

            } else {
                currentTotalWidth += width
                currentTotalWidth += Preference.spacing
                row.append(currentWord)
                i += 1
            }
        }

        result.append(row)

        return result
    }

    func processText(_ text: String) -> [String] {
        var result: [String] = []

        let paragraphs = text.components(separatedBy: "\n\n")

        for paragraph in paragraphs {
            let words = paragraph.split(separator: " ", omittingEmptySubsequences: false)
            for word in words {
                if word.isEmpty {
                    result.append(" ")
                } else {
                    result.append(String(word))
                }
            }
            result.append("\n")
        }

        if !result.isEmpty && result.last == "\n" {
            result.removeLast()
        }

        return result
    }


    func getTextSize(_ text: String) -> CGSize {
        return text.size(withAttributes: [.font: UIFont.systemFont(ofSize: Preference.fontSize)])
    }

}
