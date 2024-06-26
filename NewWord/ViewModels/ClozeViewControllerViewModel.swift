//
//  AddClozeViewControllerViewModel.swift
//  NewWord
//
//  Created by justin on 2024/6/14.
//

import UIKit

struct ClozeViewControllerViewModel {

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
    
    mutating func convertTextIntoSentences(text: String) -> [[ClozeWord]] {
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

    func retainMarker(number: Int, text: String) -> String {
        // 使用正則表達式來匹配需要保留的標記
        let retainPattern = "\\{\\{C\(number):([^}]*)\\}\\}"

        // 使用NSRegularExpression來處理正則表達式匹配
        do {
            let regex = try NSRegularExpression(pattern: "\\{\\{C\\d+:([^}]*)\\}\\}", options: [])

            // 查找符合正則表達式的匹配結果
            let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count))

            // 初始化一個可變的輸出文本
            var output = text

            // 反向迭代匹配結果，以避免在替換時改變索引
            for match in matches.reversed() {
                if let range = Range(match.range, in: text) {
                    // 獲取匹配的文本內容
                    let matchedText = text[range]

                    // 判斷是否為要保留的標記
                    let innerPattern = retainPattern
                    if let innerRegex = try? NSRegularExpression(pattern: innerPattern, options: []),
                       innerRegex.firstMatch(in: String(matchedText), options: [], range: NSRange(location: 0, length: matchedText.utf16.count)) == nil {
                        // 如果不是要保留的標記，則移除標記並保留其內部內容
                        if let innerContentRange = matchedText.range(of: "\\{\\{C\\d+:(.*?)\\}\\}", options: .regularExpression) {
                            let innerContent = matchedText[innerContentRange].dropFirst(4).dropLast(2)
                            let cleanContent = innerContent.replacingOccurrences(of: ".*:", with: "", options: .regularExpression)
                            output.replaceSubrange(range, with: String(cleanContent))
                        }
                    }
                }
            }

            return output
        } catch {
            print("正則表達式錯誤: \(error)")
            return text
        }
    }

    func removeMarkerAndReplaceWithWhitespace(number: Int, text: String) -> (text: String, range: NSRange?) {
        // 使用正則表達式來匹配指定標記
        let pattern = "\\{\\{C\(number):([^}]*)\\}\\}"

        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            
            // 查找符合正則表達式的匹配結果
            let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count))

            // 如果沒有找到匹配結果，返回原文本和nil
            guard let match = matches.first else {
                return (text, nil)
            }

            // 獲取匹配的範圍
            let matchRange = match.range

            if let range = Range(matchRange, in: text) {
                // 獲取匹配的標記文本
                let matchedText = text[range]
                
                // 獲取標記內的文本
                if let innerRange = matchedText.range(of: "\\{\\{C\(number):(.*?)\\}\\}", options: .regularExpression) {
                    let innerText = matchedText[innerRange].dropFirst(4 + "\(number)".count).dropLast(2)
                    
                    // 獲取圖形空格字符替換標記內的文本
                    let whitespace = String(repeating: "?", count: innerText.count)
                    
                    // 計算新的範圍的開始位置
                    let startIndex = text.distance(from: text.startIndex, to: range.lowerBound)
                    
                    // 獲取刪除標記後的文本
                    var output = text
                    output.replaceSubrange(range, with: whitespace)
                    
                    // 計算新的範圍
                    let newRange = NSRange(location: startIndex, length: whitespace.count)
                    return (output, newRange)
                }
            }

            return (text, nil)
        } catch {
            print("正則表達式錯誤: \(error)")
            return (text, nil)
        }
    }
    
    
    func replaceRangeWithWord(text: String, range: NSRange, word: String) -> (text: String, range: NSRange?) {
        // 確保NSRange是有效的
        guard let rangeInText = Range(range, in: text) else {
            return (text, nil)
        }
        
        // 替換範圍內的文本為新的單詞
        var newText = text
        newText.replaceSubrange(rangeInText, with: word)
        
        // 計算新範圍的位置
        let newRange = NSRange(location: range.location, length: word.count)
        
        return (newText, newRange)
    }
    
    func removePunctuation(from text: String) -> String {
        // 定義一個字符集合，包含所有標點符號
        let punctuationCharacterSet = CharacterSet.punctuationCharacters
        
        // 遍歷字符串，移除所有屬於標點符號字符集合中的字符
        let filteredText = text.unicodeScalars.filter { !punctuationCharacterSet.contains($0) }
        
        // 將過濾後的字符轉換回字符串
        return String(String.UnicodeScalarView(filteredText))
    }
    
    func applyAttributes(to text: String, range: NSRange, attributes: [NSAttributedString.Key: Any]) -> NSAttributedString? {
        // 轉換成NSMutableAttributedString以便進行屬性設置
        let attributedText = NSMutableAttributedString(string: text)
        
        // 將屬性應用於指定的範圍
        attributedText.addAttributes(attributes, range: range)
        
        return attributedText
    }

}
