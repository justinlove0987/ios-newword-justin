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

    var sentences: [[String]] = []


    mutating func splitTextIntoSentences(text: String) -> [[String]] {
        var result: [[String]] = []
        var currentSentence: [String] = []
        var currentWord = ""
        var newlineCount = 0

        let punctuationMarks: Set<Character> = [".", "!", "?"]

        for character in text {
            if character.isWhitespace {
                if !currentWord.isEmpty {
                    currentSentence.append(currentWord)
                    currentWord = ""
                }
                if character == "\n" {
                    newlineCount += 1
                } else {
                    newlineCount = 0
                }

                if newlineCount >= 2 {
                    if !currentSentence.isEmpty {
                        result.append(currentSentence)
                        currentSentence = []
                    }
                    result.append([])
                    newlineCount = 0
                }
            } else if punctuationMarks.contains(character) {
                currentWord.append(character)

                let nextIndex = text.index(after: text.firstIndex(of: character)!)

                if nextIndex < text.endIndex && text[nextIndex].isWhitespace == false {
                    currentWord.append(text[nextIndex])
                }

                currentSentence.append(currentWord)
                currentWord = ""
                result.append(currentSentence)
                
                currentSentence = []
                newlineCount = 0
            } else {
                if newlineCount > 0 {
                    newlineCount = 0
                }
                currentWord.append(character)
            }
        }

        if !currentWord.isEmpty {
            currentSentence.append(currentWord)
        }

        if !currentSentence.isEmpty {
            result.append(currentSentence)
        }

        sentences = result

        print(result)

        return result
    }

    func getTextSize(_ text: String) -> CGSize {
        return text.size(withAttributes: [.font: UIFont.systemFont(ofSize: Preference.fontSize)])
    }
}
