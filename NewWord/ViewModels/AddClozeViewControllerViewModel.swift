//
//  AddClozeViewControllerViewModel.swift
//  NewWord
//
//  Created by justin on 2024/6/14.
//

import UIKit

struct AddClozeViewControllerViewModel {
    
    struct ClozeWord {
        
        enum WordType {
            case none
            case cloze
            case multiCloze
        }
        
        var type: WordType = .none
        
        var selected: Bool = false
        
        var clozeNumber: Int?
        
        let position: (sentenceIndex: Int, wordIndex: Int)
        
        var text: String
    }

    var context: String
    let contextSize: CGSize

    var sentences: [[String]] = []
    
    mutating func convertSentencesToText(sentences: [[ClozeWord]]) -> String {
        var text: String = ""
        
        for i in 0..<sentences.count {
            let currentSentence = sentences[i]
            let isFirstSentence = i == 0
            
            if !isFirstSentence {
                text.append("\n")
            }
            
            for word in currentSentence {
                var wordText = word.text
                
                if word.selected {
                    if let clozeNumber = word.clozeNumber {
                        wordText = formatClozeText(input: wordText, clozeID: clozeNumber)
                    }
                }
                
                text.append(wordText)
                text.append(" ")
            }
        }
        
        return text
    }
    
    mutating func splitTextIntoSentences(text: String) -> [[ClozeWord]] {
        var newResult: [[ClozeWord]] = []
        var newCurrentSentence: [ClozeWord] = []
        var currentWord = ""
        var newlineCount = 0

        let punctuationMarks: Set<Character> = [".", "!", "?"]
        
        let chars = Array(text)
        var sentenceCounts = 0
        var charIndex = 0
        
        while charIndex < text.count {
            let currentChar: Character = chars[charIndex]
            
            if currentChar.isWhitespace {
                let hasWord = !currentWord.isEmpty
                
                if hasWord {
                    newCurrentSentence.append(ClozeWord(position: (sentenceCounts, newCurrentSentence.count), text: currentWord))
                    currentWord = ""
                }
                
                if currentChar == "\n" {
                    newlineCount += 1
                } else {
                    newlineCount = 0
                }

                if newlineCount >= 2 {
                    if !newCurrentSentence.isEmpty {
                        newResult.append(newCurrentSentence)
                        newCurrentSentence = []
                        sentenceCounts += 1
                    }
                    
                    newResult.append([])
                    newlineCount = 0
                    sentenceCounts += 1
                }
                
                charIndex += 1
                
            } else if punctuationMarks.contains(currentChar) {
                appendWordAndCheckNextCharacter(
                    newResult: &newResult,
                    newCurrentSentence: &newCurrentSentence,
                    currentWord: &currentWord,
                    currentCharIndex: &charIndex,
                    sentenceCounts: &sentenceCounts,
                    chars: chars)
            }
            else {
                if newlineCount > 0 {
                    newlineCount = 0
                }

                currentWord.append(currentChar)
                charIndex += 1
            }
        }
        
        if !currentWord.isEmpty {
            newCurrentSentence.append(ClozeWord(position: (sentenceCounts, newCurrentSentence.count), text: currentWord))
        }
        
        if !newCurrentSentence.isEmpty {
            newResult.append(newCurrentSentence)
            sentenceCounts += 1
        }

        return newResult
    }
    
    func appendWordAndCheckNextCharacter(
        newResult: inout [[ClozeWord]],
        newCurrentSentence: inout [ClozeWord],
        currentWord: inout String,
        currentCharIndex: inout Int,
        sentenceCounts: inout Int,
        chars: [String.Element]) {
        
        currentWord.append(chars[currentCharIndex])
        
        let hasNextChar = currentCharIndex + 1 < chars.count
        
        if hasNextChar {
            let nextChar = chars[currentCharIndex + 1]
            let nextCharIsPunctuation = nextChar.isPunctuation
            let nextCharIsWhiteSpace = nextChar.isWhitespace
            
            if nextCharIsPunctuation {
                currentCharIndex += 1
                
                appendWordAndCheckNextCharacter(
                    newResult: &newResult,
                    newCurrentSentence: &newCurrentSentence,
                    currentWord: &currentWord,
                    currentCharIndex: &currentCharIndex,
                    sentenceCounts: &sentenceCounts,
                    chars: chars)
                
            } else if nextCharIsWhiteSpace {
                let nextCharIsNewLine = nextChar.isNewline
                
                guard !nextCharIsNewLine else {
                    newCurrentSentence.append(ClozeWord(position: (sentenceCounts, newCurrentSentence.count), text: currentWord))
                    newResult.append(newCurrentSentence)
                    currentWord = ""
                    newCurrentSentence = []
                    currentCharIndex += 2
                    sentenceCounts += 1
                    return
                }
                
                if matchesAnyPattern(in: currentWord) {
                    newCurrentSentence.append(ClozeWord(position: (sentenceCounts, newCurrentSentence.count), text: currentWord))
                    currentWord = ""
                    currentCharIndex += 1
                    
                } else {
                    newCurrentSentence.append(ClozeWord(position: (sentenceCounts, newCurrentSentence.count), text: currentWord))
                    newResult.append(newCurrentSentence)
                    currentWord = ""
                    newCurrentSentence = []
                    currentCharIndex += 2
                    sentenceCounts += 1
                }
                
            } else {
                currentCharIndex += 1
            }
            
        } else {
            currentCharIndex += 1
        }
    }
    
    func matchesAnyPattern(in text: String) -> Bool {
        let patterns: [String] = ["(?<!\\.)\\.\\.\\.$",
                                  "\\b(Mr|Mrs|Ms|Dr|Prof|St|Jr|Sr|Ltd|Inc|Co|Corp|Gen|Col|Sgt|Lt|Mt|Fr|Rev|Hon)\\."]
        
        for pattern in patterns {
            do {
                let regex = try NSRegularExpression(pattern: pattern)
                let range = NSRange(location: 0, length: text.utf16.count)
                if regex.firstMatch(in: text, options: [], range: range) != nil {
                    return true
                }
            } catch {
                print("Invalid regex pattern: \(pattern)")
            }
        }
        return false
    }
    
    func getTextSize(_ text: String) -> CGSize {
        return text.size(withAttributes: [.font: UIFont.systemFont(ofSize: Preference.fontSize)])
    }
    
    func formatClozeText(input: String, clozeID: Int) -> String {
        let punctuationPattern = "^([^\\w]*)([\\w]+)([^\\w]*)$"
        
        guard let regex = try? NSRegularExpression(pattern: punctuationPattern, options: []) else {
            return input
        }
        
        let range = NSRange(location: 0, length: input.utf16.count)
        if let match = regex.firstMatch(in: input, options: [], range: range) {
            let leadingPunctuation = (match.range(at: 1).location != NSNotFound) ? String(input[Range(match.range(at: 1), in: input)!]) : ""
            let coreWord = (match.range(at: 2).location != NSNotFound) ? String(input[Range(match.range(at: 2), in: input)!]) : input
            let trailingPunctuation = (match.range(at: 3).location != NSNotFound) ? String(input[Range(match.range(at: 3), in: input)!]) : ""

            let formattedWord = "{{C\(clozeID):\(coreWord)}}"

            return "\(leadingPunctuation)\(formattedWord)\(trailingPunctuation)"
        }

        return input
    }

    func extractNumberAndCoreWord(from input: String) -> (Int, String)? {
        let clozePattern = "\\{\\{C(\\d+):(.*?)\\}\\}"

        guard let regex = try? NSRegularExpression(pattern: clozePattern, options: []) else {
            return nil
        }

        let range = NSRange(location: 0, length: input.utf16.count)
        if let match = regex.firstMatch(in: input, options: [], range: range) {
            if let numberRange = Range(match.range(at: 1), in: input),
               let coreWordRange = Range(match.range(at: 2), in: input) {
                let numberString = String(input[numberRange])
                let coreWord = String(input[coreWordRange])

                if let number = Int(numberString) {
                    let surroundingText = input.replacingOccurrences(of: "\\{\\{C\\d+:(.*?)\\}\\}", with: coreWord, options: .regularExpression, range: input.range(of: input))

                    return (number, surroundingText)
                }
            }
        }

        return nil
    }
}
