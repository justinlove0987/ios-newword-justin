//
//  AddClozeViewController.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/6/4.
//

import UIKit

class AddClozeViewController: UIViewController, StoryboardGenerated {
    
    static var storyboardName: String = K.Storyboard.main
    
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addContextRevisionInputAccessoryView()
    }
    
    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
    }
    
    private func addContextRevisionInputAccessoryView() {
        let view = ContextRevisionInputAccessoryView()
        view.frame = CGRect(x: 0, y: 0, width: 0, height: 50)
        view.delegate = self
        textView.inputAccessoryView = view
        textView.becomeFirstResponder()
    }
    
}

extension AddClozeViewController: ContextRevisionInputAccessoryViewDelegate {
    func didTapseperateParagraphWithSingleLineActionButton(_ sender: UIView) {
        guard let text = textView.text else { return }
        
        let newText = separateParagraphsWithSingleLine(text: text)
        textView.text = newText
        textView.resignFirstResponder()
    }
    
    func didAddNewLineAfterPeriodsButton(_ sender: UIView) {
        guard let text = textView.text else { return }
        
        let newText = addNewlineAfterPeriods(text: text)
        textView.text = newText
        textView.resignFirstResponder()
    }
    
    func didTapCleanChineseButton(_ sender: UIView) {
        let text = textView.text!
        let newText = removeChineseParagraphs(from: text)
        textView.text = newText
        textView.resignFirstResponder()
    }
    
    func separateParagraphsWithSingleLine(text: String) -> String {
        let pattern = "\n+"
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(location: 0, length: text.utf16.count)
        let newText = regex.stringByReplacingMatches(in: text, options: [], range: range, withTemplate: "\n")
        return newText
    }
    
    private func addNewlineAfterPeriods(text: String) -> String {
        let newText = text.replacingOccurrences(of: ". ", with: ".\n")
        return newText
    }

    private func removeChineseParagraphs(from text: String) -> String {
        // 定義正則表達式來匹配包含中文字符的段落
        let pattern = ".*[\\u4e00-\\u9fff]+.*"

        // 創建正則表達式實例
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return text
        }

        // 將文本分成段落
        let paragraphs = text.components(separatedBy: "\n")

        // 過濾掉包含中文字符的段落
        let filteredParagraphs = paragraphs.filter { paragraph in
            let range = NSRange(location: 0, length: paragraph.utf16.count)
            return regex.firstMatch(in: paragraph, options: [], range: range) == nil
        }

        // 將過濾後的段落重新組合成文本
        return filteredParagraphs.joined(separator: "\n")
    }
}
