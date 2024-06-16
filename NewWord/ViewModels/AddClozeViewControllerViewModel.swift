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
        
        var selected: Bool = false
        
        let type: WordType = .none
        
        let position: (sentenceIndex: Int, wordIndex: Int)
        
        let text: String
    }

    var context: String
    let contextSize: CGSize

    var sentences: [[String]] = []
    
    mutating func splitTextIntoSentences(text: String) -> [[ClozeWord]] {
        var newResult: [[ClozeWord]] = []
        var result: [[String]] = []
        var newCurrentSentence: [ClozeWord] = []
        var currentSentence: [String] = []
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
                    currentSentence.append(currentWord)
                    currentWord = ""
                }
                
                if currentChar == "\n" {
                    newlineCount += 1
                } else {
                    newlineCount = 0
                }

                if newlineCount >= 2 {
                    if !currentSentence.isEmpty {
                        newResult.append(newCurrentSentence)
                        result.append(currentSentence)
                        newCurrentSentence = []
                        currentSentence = []
                        sentenceCounts += 1
                    }
                    
                    newResult.append([])
                    result.append([])
                    newlineCount = 0
                    sentenceCounts += 1
                }
                
                charIndex += 1
                
            } else if punctuationMarks.contains(currentChar) {
                appendWordAndCheckNextCharacter(
                    newResult: &newResult,
                    result: &result,
                    newCurrentSentence: &newCurrentSentence,
                    currentSentence: &currentSentence,
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
            currentSentence.append(currentWord)
        }
        
        if !currentSentence.isEmpty {
            newResult.append(newCurrentSentence)
            result.append(currentSentence)
            sentenceCounts += 1
        }

        sentences = result

        return newResult
    }
    
    func appendWordAndCheckNextCharacter(
        newResult: inout [[ClozeWord]],
        result: inout [[String]],
        newCurrentSentence: inout [ClozeWord],
        currentSentence: inout [String],
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
                    result: &result,
                    newCurrentSentence: &newCurrentSentence,
                    currentSentence: &currentSentence,
                    currentWord: &currentWord,
                    currentCharIndex: &currentCharIndex,
                    sentenceCounts: &sentenceCounts,
                    chars: chars)
                
            } else if nextCharIsWhiteSpace {
                let nextCharIsNewLine = nextChar.isNewline
                
                guard !nextCharIsNewLine else {
                    currentCharIndex += 1
                    return
                }
                
                if matchesAnyPattern(in: currentWord) {
                    newCurrentSentence.append(ClozeWord(position: (sentenceCounts, newCurrentSentence.count), text: currentWord))
                    currentSentence.append(currentWord)
                    currentWord = ""
                    currentCharIndex += 1
                    
                } else {
                    newCurrentSentence.append(ClozeWord(position: (sentenceCounts, newCurrentSentence.count), text: currentWord))
                    currentSentence.append(currentWord)
                    newResult.append(newCurrentSentence)
                    result.append(currentSentence)
                    currentWord = ""
                    currentSentence = []
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
    
    func returnPatterns(_ text: String) -> Bool {
        
        if endsWithExactlyThreeDots(text: text) {
            return true
        }
        
        
        return false
    }
    
    func endsWithExactlyThreeDots(text: String) -> Bool {
        return text.hasSuffix("...") && text.suffix(4) != "...."
    }
    
    func getTextSize(_ text: String) -> CGSize {
        return text.size(withAttributes: [.font: UIFont.systemFont(ofSize: Preference.fontSize)])
    }
}
