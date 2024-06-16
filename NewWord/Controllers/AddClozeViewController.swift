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
    @IBOutlet weak var tableView: UITableView!

    private var viewModel: AddClozeViewControllerViewModel!

    var dataSource: [[String]] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    private var currentText: String = "" {
        didSet {
            textView.text = currentText
            viewModel.context = currentText
            dataSource = viewModel.splitTextIntoSentences(text: currentText)
        }
    }

    // MARK: - Lifcycles

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    // MARK: - Helpers

    private func setup() {
        setupViewModel()
        setupInputView()
        setupTableView()
    }

    private func setupTableView() {
        tableView.register(ContextCell.self, forCellReuseIdentifier: "ContextCell")
        tableView.isHidden = true

        currentText =
        """
When we think about punctuation, we often remember the basics: the period, the comma, and the question mark. However, there's so much more! Consider the exclamation mark—wow! It adds excitement, doesn't it? Additionally, the colon: a punctuation mark that introduces lists or explanations.

Think about parentheses (they're quite handy) or brackets [useful for adding information]. Then there's the semicolon; it connects related ideas. Don't forget about quotation marks: "They highlight speech or quotations."

In academic writing, you'll encounter the dash—an elegant way to interject thoughts. Plus, the ellipsis... it creates suspense. Finally, remember the apostrophe's role in contractions and possession, and the hyphen in compound words like well-known.

All these marks—yes, all of them—help us write clearly, expressively, and precisely!
"""
        dataSource = viewModel.splitTextIntoSentences(text: currentText)

    }

    private func setupViewModel() {
        guard let text = textView.text else { return }
        viewModel = AddClozeViewControllerViewModel(context: text, contextSize: view.frame.size)
    }

    private func setupInputView() {
        let view = ContextRevisionInputAccessoryView()
        view.frame = CGRect(x: 0, y: 0, width: 0, height: 50)
        view.delegate = self
        textView.inputAccessoryView = view
        textView.becomeFirstResponder()
    }

    // MARK: - Actions

    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        let shouldShowTextView = sender.selectedSegmentIndex == 0

        textView.isHidden = !shouldShowTextView
        tableView.isHidden = shouldShowTextView

        if !shouldShowTextView {
            textView.resignFirstResponder()
        }
    }

}

// MARK: - ContextRevisionInputAccessoryViewDelegate

extension AddClozeViewController: ContextRevisionInputAccessoryViewDelegate {
    func didTapTotalAction(_ sender: UIView) {
        guard let text = textView.text else { return }

        var newText = addNewlineAfterPeriods(text: text)
        newText = removeChineseParagraphs(from: newText)
        newText = separateParagraphsWithSingleLine(text: newText)

        currentText = newText

        textView.resignFirstResponder()
    }
    
    func didTapseperateParagraphWithSingleLineActionButton(_ sender: UIView) {
        guard let text = textView.text else { return }

        currentText = separateParagraphsWithSingleLine(text: text)

        textView.resignFirstResponder()
    }
    
    func didAddNewLineAfterPeriodsButton(_ sender: UIView) {
        guard let text = textView.text else { return }

        currentText = addNewlineAfterPeriods(text: text)

        textView.resignFirstResponder()
    }
    
    func didTapCleanChineseButton(_ sender: UIView) {
        guard let text = textView.text else { return }

        currentText = removeChineseParagraphs(from: text)

        textView.resignFirstResponder()
    }
    
    private func addNewlineAfterPeriods(text: String) -> String {
        let newText = text.replacingOccurrences(of: ". ", with: ". \n")
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

    func separateParagraphsWithSingleLine(text: String) -> String {
        let pattern = "\n{2,}"  // Match two or more consecutive newlines
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(location: 0, length: text.utf16.count)
        let newText = regex.stringByReplacingMatches(in: text, options: [], range: range, withTemplate: "\n\n")
        return newText
    }

    func getLines(from textView: UITextView) -> [[String]] {
        var lines: [[String]] = []
        let text = textView.text as NSString
        let layoutManager = textView.layoutManager
        var lineRange: NSRange = NSRange(location: 0, length: 0)
        var glyphIndex = 0

        while glyphIndex < layoutManager.numberOfGlyphs {
            layoutManager.lineFragmentRect(forGlyphAt: glyphIndex, effectiveRange: &lineRange)
            let lineText = text.substring(with: lineRange)
            let words = lineText.split(separator: " ").map { String($0) }
            lines.append(words)
            glyphIndex = NSMaxRange(lineRange)
        }

        return lines
    }
}

// MARK: - UITableViewDataSource

extension AddClozeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContextCell", for: indexPath) as! ContextCell

        cell.configureCell(with: dataSource[indexPath.row])

        return cell
    }

}
