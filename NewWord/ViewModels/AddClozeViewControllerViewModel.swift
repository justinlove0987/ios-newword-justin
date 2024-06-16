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
            
        let chars = Array(text)
        var charIndex = 0
        
        while charIndex < text.count {
            let currentChar: Character = chars[charIndex]
            
            if currentChar.isWhitespace {
                let hasWord = !currentWord.isEmpty
                
                if hasWord {
                    currentSentence.append(currentWord)
                    currentWord = ""
                }
                
                if currentChar == "\n" {
                    newlineCount += 1
                } else {
                    newlineCount = 0
                }
                
                if currentChar == "\n" {
                    
                }

                if newlineCount >= 2 {
                    if !currentSentence.isEmpty {
                        result.append(currentSentence)
                        currentSentence = []
                    }
                    
                    result.append([])
                    newlineCount = 0
                }
                
                charIndex += 1
                
            } else if punctuationMarks.contains(currentChar) {
                appendWordAndCheckNextCharacter(
                    sentences: &result,
                    currentSentence: &currentSentence,
                    currentWord: &currentWord,
                    currentCharIndex: &charIndex,
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
            currentSentence.append(currentWord)
        }
        
        if !currentSentence.isEmpty {
            result.append(currentSentence)
        }

        sentences = result

        return result
    }
    
    func appendWordAndCheckNextCharacter(
        sentences: inout [[String]],
        currentSentence: inout [String],
        currentWord: inout String,
        currentCharIndex: inout Int,
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
                    sentences: &sentences,
                    currentSentence: &currentSentence,
                    currentWord: &currentWord,
                    currentCharIndex: &currentCharIndex,
                    chars: chars)
                
            } else if nextCharIsWhiteSpace {
                let nextCharIsNewLine = nextChar.isNewline
                
                guard !nextCharIsNewLine else {
                    currentCharIndex += 1
                    return
                }
                
                if endsWithExactlyThreeDots(text: currentWord) {
                    currentSentence.append(currentWord)
                    currentWord = ""
                    currentCharIndex += 1
                } else {
                    currentSentence.append(currentWord)
                    sentences.append(currentSentence)
                    currentWord = ""
                    currentSentence = []
                    currentCharIndex += 2
                }
                
            } else {
                currentCharIndex += 1
            }
            
        } else {
            currentCharIndex += 1
        }
    }
    
    func endsWithExactlyThreeDots(text: String) -> Bool {
        return text.hasSuffix("...") && text.suffix(4) != "...."
    }
    
    func getTextSize(_ text: String) -> CGSize {
        return text.size(withAttributes: [.font: UIFont.systemFont(ofSize: Preference.fontSize)])
    }
}
