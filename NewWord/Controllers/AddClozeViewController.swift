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
    
    typealias ClozeWord = AddClozeViewControllerViewModel.ClozeWord
    
    var clozeNumbers: [Int] = []

    var dataSource: [[ClozeWord]] = [] {
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
        setupNotifications()
    }

    private func setupTableView() {
        tableView.register(ContextCell.self, forCellReuseIdentifier: "ContextCell")
        tableView.isHidden = true

        currentText =
        """
In... the bustling town of Punctuatia, lived an eccentric scholar named Dr. Punctuation. One sunny day, his apprentice, Lily, asked, "Dr. Punctuation, can you teach me about punctuation?"

Dr. Punctuation smiled, "Of course, Lily! Let's start with the basics. A period (.) ends a sentence, like this: 'The sun rises.' A comma (,) separates items in a list: 'I bought apples, oranges, and bananas.'"

Lily asked, "What about semicolons and colons?"

"Good question!" Dr. Punctuation replied. "A semicolon (;) links related clauses: 'She writes; he reads.' A colon (:) introduces a list or explanation: 'I need the following: paper, pen, and ink.'"

Lily's eyes widened. "What about exclamation marks and question marks?"

"Exclamation marks (!) show excitement: 'Wow!' Question marks (?) indicate a query: 'How are you?'" Dr. Punctuation explained.

"Don't forget about quotation marks and apostrophes," Lily added.

"Correct! Quotation marks (' ' or " ") enclose direct speech: 'He said, "Hello."' Apostrophes (') show possession: 'Lily's book,' or contractions: 'don't,'" he elaborated.

"And parentheses?" Lily asked.

"Parentheses (()) add extra information: 'He gave me a gift (a book),'" Dr. Punctuation noted. "Brackets ([]) add editorial comments: 'She [the teacher] was kind.'"

"Hyphens and dashes?" Lily continued.

"Hyphens (-) join words: 'well-known author.' Dashes (—) add emphasis: 'She was happy—really happy,'" he said.

Lily grinned, "Thanks, Dr. Punctuation! I think I've got it now."

"You're welcome, Lily," he chuckled. "Practice makes perfect!"

And so, Lily learned the art of punctuation, one mark at a time.
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
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateDataSource(_:)), name: .didTapContextLabel, object: nil)
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
    
    @objc func handleUpdateDataSource(_ sender: Notification) {
        guard let clozeWordCallBack = sender.object as? ClozeWord else { return }
        
        let position = clozeWordCallBack.position
        let isSelected = dataSource[position.sentenceIndex][position.wordIndex].selected
        
        if isSelected {
            guard let clozeNumber = dataSource[position.sentenceIndex][position.wordIndex].clozeNumber else { return }
            clozeNumbers.removeAll { $0 == clozeNumber }
            
        } else {
            var newClozeNumber = clozeNumbers.count + 1
            
            while clozeNumbers.contains(newClozeNumber) {
                newClozeNumber += 1
            }
            
            clozeNumbers.append(newClozeNumber)
            
            dataSource[position.sentenceIndex][position.wordIndex].clozeNumber = newClozeNumber
        }
        
        dataSource[position.sentenceIndex][position.wordIndex].selected = clozeWordCallBack.selected
        
        let text = viewModel.convertSentencesToText(sentences: dataSource)
        textView.text = text
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
