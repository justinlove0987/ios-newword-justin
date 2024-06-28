//
//  SearchClozeResultCell.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/6/28.
//

import UIKit
import NaturalLanguage

// TODO: wellknown還會處理

class SearchClozeResultCell: UITableViewCell {
    
    static let reuseIdentifier = "SearchClozeResultCell"

    @IBOutlet weak var contentLabel: UILabel!
    
    
    func updateUI(_ cloze: CDCloze) {
        guard let context = cloze.context?.text else { return }
        let number = Int(cloze.number)
        
        let attributedString = findSentenceAndHighlightMarker(number: number, context: context)
        
        contentLabel.attributedText = attributedString
    }
    
    func findSentenceAndHighlightMarker(number: Int, context: String) -> NSAttributedString? {
        // 使用正則表達式來匹配指定標記
        let pattern = "\\{\\{C\(number):([^}]*)\\}\\}"

        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            
            // 查找符合正則表達式的匹配結果
            let matches = regex.matches(in: context, options: [], range: NSRange(location: 0, length: context.utf16.count))

            // 如果沒有找到匹配結果，返回nil
            guard let match = matches.first else {
                return nil
            }

            // 獲取匹配的範圍
            let matchRange = match.range

            if let range = Range(matchRange, in: context) {
                // 獲取匹配的標記文本
                let matchedText = context[range]
                
                // 獲取標記內的文本
                if let innerRange = matchedText.range(of: "\\{\\{C\(number):(.*?)\\}\\}", options: .regularExpression) {
                    let innerText = String(matchedText[innerRange].dropFirst(4 + "\(number)".count).dropLast(2))
                    
                    // 分割句子，避免處理標點符號中的.
                    var sentences = [String]()
                    let tokenizer = NLTokenizer(unit: .sentence)
                    tokenizer.string = context
                    tokenizer.enumerateTokens(in: context.startIndex..<context.endIndex) { tokenRange, _ in
                        sentences.append(String(context[tokenRange]))
                        return true
                    }

                    // 查找包含該標記的句子
                    var targetSentence: String? = nil
                    for sentence in sentences {
                        if sentence.contains(matchedText) {
                            targetSentence = sentence
                            break
                        }
                    }

                    // 如果找不到包含標記的句子，返回nil
                    guard let sentence = targetSentence else {
                        return nil
                    }

                    // 刪除句子中的所有標記
                    let updatedSentence = sentence.replacingOccurrences(of: "\\{\\{C\\d+:(.*?)\\}\\}", with: "$1", options: .regularExpression)

                    // 創建NSMutableAttributedString並應用藍色背景
                    let sentenceString = updatedSentence.trimmingCharacters(in: .whitespacesAndNewlines) // Trim all whitespace and newline characters
                    let attributedString = NSMutableAttributedString(string: sentenceString)
                    let nsRange = (sentenceString as NSString).range(of: innerText)
                    
                    // 應用藍色背景
                    attributedString.addAttribute(.backgroundColor, value: UIColor.blue, range: nsRange)
                    
                    return attributedString
                }
            }

            return nil
        } catch {
            print("正則表達式錯誤: \(error)")
            return nil
        }
    }
    
    
//    func test(_ cloze: CDCloze) {
//        guard let context = cloze.context?.text else { return }
//        let number = Int(cloze.number)
//        
//        let tokenizer = NLTokenizer(unit: .sentence)
//
//    }
//    
//    func tokenizeTextIntoSentences(_ text: String) -> [String] {
//        let tokenizer = NLTokenizer(unit: .sentence)
//        tokenizer.string = text
//        
//        var sentences: [String] = []
//        
//        tokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) { (range, _) in
//            let sentence = String(text[range])
//            sentences.append(sentence)
//            return true
//        }
//        
//        return sentences
//    }
//    
}
