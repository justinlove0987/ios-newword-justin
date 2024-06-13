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

    private var currentText: String = "" {
        didSet {
            textView.text = currentText
            viewModel.context = currentText
            tableView.reloadData()
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
The AI technology, developed internally by Walmart, allows employees to scan items like bananas to determine their ripeness. A digital dashboard then uses generative AI to suggest the best course of action, such as changing the price, returning the product to the vendor, or donating it. This eliminates the need for human decision-making in the absence of informed advice, enabling associates to take proactive steps to reduce waste in stores.
"""
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
    
    func separateParagraphsWithSingleLine(text: String) -> String {
        let pattern = "\n+"
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(location: 0, length: text.utf16.count)
        let newText = regex.stringByReplacingMatches(in: text, options: [], range: range, withTemplate: "\n\n")
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

// MARK: - UITableViewDataSource

extension AddClozeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getRows().count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rows = viewModel.getRows()

        let cell = tableView.dequeueReusableCell(withIdentifier: "ContextCell", for: indexPath) as! ContextCell

        cell.configureCell(with: rows[indexPath.row])

        return cell
    }

}
