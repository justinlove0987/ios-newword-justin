//
//  ClozeViewViewModel.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/6/9.
//

import Foundation

struct ClozeViewViewModel {
    
    var card: CDCard?

    var clozeText: String?

    var dummyText = "[...]"

    func getQuestionText() -> String? {
        guard let card else { return nil }

        guard let cloze = card.note?.noteType?.cloze else { return nil }
        guard let text = cloze.context?.text else { return nil }
        guard let id = cloze.id else { return nil }
        
        let newText = text.replacingOccurrences(of: "\\{\\{C\(id):\\w+\\}\\}", with: dummyText, options: .regularExpression)

        return newText
    }

    func getClozeText() -> String? {
        guard let card else { return nil }
        guard let cloze = card.note?.noteType?.cloze else { return nil }
        guard let text = cloze.context?.text else { return nil }
        guard let id = cloze.id else { return nil }

        let pattern = "\\{\\{C\(id):([^\\}]+)\\}\\}"

        do {
            let regex = try NSRegularExpression(pattern: pattern)

            if let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)) {
                if let range = Range(match.range(at: 1), in: text) {
                    return String(text[range])
                }
            }
        } catch {
            print("Invalid regex: \(error.localizedDescription)")
        }

        return nil
    }

    func getAnswerText(from text: String) -> String? {
        guard let clozeText = getClozeText() else { return nil }

        let newText = text.replacingOccurrences(of: dummyText, with: clozeText)

        return newText

    }

}
