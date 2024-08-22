//
//  NewAddClozeViewControllerViewModel.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/7/1.
//

import UIKit
import OpenCC
import NaturalLanguage
import SwiftKit

struct WordSelectorViewControllerViewModel {
    
    typealias TagType = Tag.TagType

    enum SelectMode: Int, CaseIterable {
        case word
        case sentence

        var title: String {
            switch self {
            case .word:
                return "單字"
            case .sentence:
                return "句子"
            }
        }
    }

    struct ColorSegment: Comparable {
        
        let tagColor: UIColor
        let contentColor: UIColor
        let clozeLocation: Int
        let clozeLength: Int
        var heightFraction: Double = 0.0
        var segmentIndex: Int?
        var tagNumber: Int?

        var isTag: Bool {
            guard segmentIndex != nil else { return false }

            return true
        }

        var isFirstTagInSegment: Bool {
            guard isTag else { return false }

            return segmentIndex == 0
        }

        static func < (lhs: ColorSegment, rhs: ColorSegment) -> Bool {
            if lhs.clozeLocation == rhs.clozeLocation {
                return lhs.clozeLength > rhs.clozeLength
            }
            return lhs.clozeLocation < rhs.clozeLocation
        }
    }
    
    struct ColoredMark {
        let characterIndex: Int
        var colorSegments: [ColorSegment]
    }
    
    struct ColoredText {
        struct CharacterIndex: Hashable {
            let index: Int
            var isFirstIndex: Bool = false
            
            func hash(into hasher: inout Hasher) {
                hasher.combine(index)
            }

            static func == (lhs: CharacterIndex, rhs: CharacterIndex) -> Bool {
                return lhs.index == rhs.index
            }
        }
        
        var coloredCharacters: [CharacterIndex: [ColorSegment]]
    }
    
    var tags: [Tag] = []
    
    var selectMode: SelectMode = .word
    
    var currentSelectedRange: NSRange?
    
    var translationPairs: [TranslationPair] = []

    mutating func getClozeNumber() -> Int {
        let clozeNumbers = tags.map { $0.number }
        
        if clozeNumbers.isEmpty {
            return 1
        }
        
        var maxClozeNumber = clozeNumbers.max()
        
        maxClozeNumber! += 1
        
        if clozeNumbers.contains(maxClozeNumber!) {
            while clozeNumbers.contains(maxClozeNumber! + 1) {
                maxClozeNumber! += 1
            }
        }
        
        return maxClozeNumber!
    }

    func getUpdatedRange(range: NSRange, offset: Int) -> NSRange {
        let location = range.location

        for cloze in tags {
            let currentLocation = cloze.range.location
            let isSameLocation = location == currentLocation

            if isSameLocation {
                return range
            }
        }

        return NSRange(location: range.location+offset, length: range.length)
    }
    
    mutating func removeAllTags(in text: String) -> String {
        var text = text
        let uniqueClozeIndices = getUniqueLocationClozeIndices()

        for i in uniqueClozeIndices {
            let currentCloze = tags[i]
            let offset = -1
            let tagLocation = currentCloze.range.location-1
            
            let tagRange = NSRange(location: tagLocation, length: 1)
            
            if let tagIndex = currentCloze.getTagIndex(in: text) {
                text.remove(at: tagIndex)
                updateTagNSRanges(with: tagRange, offset: offset)
            }
        }
        
        return text
    }

    mutating func saveTag(_ text: String) {
        let context = CoreDataManager.shared.createContext(text)
        
        for i in 0..<tags.count {
            let currentCloze = tags[i]
            
            guard let word = textInRange(text: text, range: currentCloze.range),
                  let deck = getSaveDeck(currentCloze) else {
                continue
            }
            
            let newCloze = CoreDataManager.shared.createCloze(number: currentCloze.number, hint: "", clozeWord: currentCloze.text)
            
            newCloze.context = context
            newCloze.contextId = context.id
            newCloze.clozeWord = word
            newCloze.location = Int64(currentCloze.range.location)
            newCloze.length = Int64(currentCloze.range.length)
            newCloze.hint = currentCloze.translatedText
            
            GoogleTTSService.shared.download(text: word) { data in
                newCloze.clozeAudio = data
                CoreDataManager.shared.save()
            }
            
            let resource = CoreDataManager.shared.createNoteResource()
            resource.cloze = newCloze
            
            let note = CoreDataManager.shared.createNote(typeRawValue: NoteType.lienteningCloze.rawValue)
            note.resource = resource
            
            CoreDataManager.shared.addCard(to: deck, with: note)
        }
        
        CoreDataManager.shared.save()
    }
    
    func textInRange(text: String, range: NSRange) -> String? {
        guard let rangeInString = Range(range, in: text) else { return nil }
        return String(text[rangeInString])
    }
    
    func containsTag(textType: TextType, tagType: TagType, range: NSRange) -> Bool {
        for i in 0..<tags.count {
            let currentTag = tags[i]
            
            let tagExists = currentTag.isEqualTo(textType: textType, tagType: tagType, range: range)
            
            if tagExists {
                return true
            }
        }
        
        return false
    }
    
    func containsOriginalText(_ text: String) -> Bool {
        return translationPairs.contains { $0.originalText == text }
    }
    
    func getTranslatedText(_ text: String) -> String? {
        let translationPair = translationPairs.first { translationPair in
            return translationPair.originalText == text
        }
        
        return translationPair?.translatedText
    }
    
    mutating func removeCloze(_ range: NSRange) {
        for i in 0..<tags.count {
            let currentCloze = tags[i]

            let findCloze = currentCloze.range == range
            
            if findCloze {
                tags.remove(at: i)
                break
            }
        }
    }

    func hasDuplicateClozeLocations(with range: NSRange) -> Bool {
        for i in 0..<tags.count {
            let currentCloze = tags[i]
            let currentLocation = currentCloze.range.location
            let hasDuplicates = range.location == currentLocation

            if hasDuplicates {
                return true
            }
        }

        return false
    }
    
    func hasAnyTag() -> Bool {
        return !tags.isEmpty
    }
    
    
    func updateAudioRange(tagPosition: Int, adjustmentOffset: Int, article: inout FSArticle?) {
        guard let copyArticle = article else { return }
        guard let result = copyArticle.ttsSynthesisResult else { return }
        
        for i in 0..<result.timepoints.count {
            let timepoint = result.timepoints[i]
            
            guard let range = timepoint.range else { continue }
            
            let isGreaterThanTagPosition = range.location >= tagPosition
            
            if isGreaterThanTagPosition {
                article!.ttsSynthesisResult!.timepoints[i].range!.location += adjustmentOffset
            }
        }
    }
    
    /// 在加入cloze前update就不須理會新的cloze是否在array中
    mutating func updateTagNSRanges(with newNSRange: NSRange, offset: Int) {
        for i in 0..<tags.count {
            let currentCloze = tags[i]

            if newNSRange.location == currentCloze.range.location {
                return
            }
        }

        for i in 0..<tags.count {
            let currentCloze = tags[i]
            let newLocation = newNSRange.location
            let currentLocation = currentCloze.range.location
            let currentLength = currentCloze.range.length

            if newLocation < currentLocation {
                tags[i].range = NSRange(location: currentLocation + offset, length: currentLength)

            } else if newLocation > currentLocation && newLocation < currentLocation + currentLength {
                tags[i].range = NSRange(location: currentLocation, length: currentLength+offset)
            }
        }
    }

    func createNewTag(number: Int, 
                        cloze: String,
                        range: NSRange,
                        textType: TextType,
                        hint: String) -> Tag {
        
        var newCloze: Tag
        let tagColor: UIColor = selectMode == .sentence ? UIColor.tagBlue : UIColor.tagGreen
        let cotentColor: UIColor = selectMode == .sentence ? UIColor.clozeBlueText: UIColor.textGreen
        let id = UUID().uuidString
        
        newCloze = Tag(id: id, number: number, text: cloze, range: range, tagColor: tagColor, contentColor: cotentColor, translatedText: hint, textType: textType)

        return newCloze
    }

    mutating func appendCloze(_ cloze: Tag) {
        tags.append(cloze)
    }
    
    func getUniqueLocationClozeIndices() -> [Int] {
        var uniqueLocations: Set<Int> = .init()
        var indices: [Int] = []

        for i in 0..<tags.count {
            let currentCloze = tags[i]
            let location = currentCloze.range.location
            
            if !uniqueLocations.contains(location) {
                indices.append(i)
                uniqueLocations.insert(location)
            }
        }
        
        return indices
    }
    
    func isWhitespace(_ string: String) -> Bool {
        let whitespaceCharacterSet = CharacterSet.whitespacesAndNewlines
        return string.trimmingCharacters(in: whitespaceCharacterSet).isEmpty
    }
    
    func getNSRanges() -> [NSRange] {
        return tags.map { $0.range }
    }
    
    func createColoredText() -> ColoredText {
        var result = ColoredText(coloredCharacters: [:])

        for i in 0..<tags.count {
            let current = tags[i]
            let nsRange = current.range
            let location = nsRange.location
            
            for i in 0..<nsRange.length {
                let index = location + i
                let isFirstIndex = location == index

                let newSegment = ColorSegment(tagColor: current.tagColor,
                                              contentColor: current.contentColor,
                                              clozeLocation: location,
                                              clozeLength: nsRange.length, tagNumber: current.number)
                
                var characterindex = ColoredText.CharacterIndex(index: index)

                characterindex.isFirstIndex = location == index

                if result.coloredCharacters[characterindex] != nil {
                    result.coloredCharacters[characterindex]!.append(newSegment)

                    if isFirstIndex  {
                        let value = result.coloredCharacters[characterindex]!
                        result.coloredCharacters.removeValue(forKey: characterindex)
                        result.coloredCharacters[characterindex] = value
                    }

                } else {
                    result.coloredCharacters[characterindex] = [newSegment]
                }
            }
        }

        return result
    }
    
    func calculateColoredTextHeightFraction() -> ColoredText {
        let coloredText = createColoredText()
        var newColoredText: ColoredText = .init(coloredCharacters: [:])
        
        for (characterIndex, colorSegments) in coloredText.coloredCharacters {
            var colorSegments = colorSegments
            
            var remainingHeightFraction: Double = 1.0
            var currentIndex = 0
            
            colorSegments.sort()
            
            while currentIndex < colorSegments.count {
                var overlappingCount = 0
                
                countOverlapping(currentIndex: currentIndex, elements: colorSegments, count: &overlappingCount)
                
                let hasOverLapping = overlappingCount > 0

                if hasOverLapping {
                    let fraction = remainingHeightFraction / Double((overlappingCount+1))
                    
                    for segmentIndex in 0..<overlappingCount + 1 {
                        colorSegments[currentIndex].heightFraction = fraction
                        remainingHeightFraction -= fraction

                        if characterIndex.isFirstIndex {
                            colorSegments[currentIndex].segmentIndex = segmentIndex
                        }

                        currentIndex += 1
                    }
                    
                } else {
                    let isLastOne = currentIndex + 1 == colorSegments.count
                    
                    if isLastOne {
                        colorSegments[currentIndex].heightFraction = remainingHeightFraction

                        if characterIndex.isFirstIndex {
                            colorSegments[currentIndex].segmentIndex = 0
                        }

                    } else {
                        let fraction = remainingHeightFraction*0.1
                        colorSegments[currentIndex].heightFraction = fraction
                        remainingHeightFraction -= fraction
                    }

                    currentIndex += 1
                }
            }

            newColoredText.coloredCharacters[characterIndex] = colorSegments
        }
        
        return newColoredText
    }
    
    func createColoredMarks(_ coloredText: ColoredText) -> [ColoredMark] {
        var result: [ColoredMark] = []
        
        for (characterIndex, colorSegments) in coloredText.coloredCharacters {
            if characterIndex.isFirstIndex {
                let offset = 1
                let coloredMark = ColoredMark(characterIndex: characterIndex.index-offset, colorSegments: colorSegments)

                result.append(coloredMark)
            }
        }
        
        return result
    }

    private func countOverlapping(currentIndex: Int, elements: [ColorSegment], count: inout Int) {
        let current = elements[currentIndex]
        
        let hasNext = currentIndex + 1 < elements.count
        
        if hasNext {
            let next = elements[currentIndex+1]
            let isOverlapping = current.clozeLocation == next.clozeLocation
            
            if isOverlapping {
                count += 1
                countOverlapping(currentIndex: currentIndex+1, elements: elements, count: &count)
            }
        }
    }

    func translateEnglishToChinese(_ text: String, completion: @escaping (String?) -> Void) {

        let english = Locale(identifier: "en")
        let chinese = Locale(identifier: "zh-TW")

        GoogleCloudTranslationService.shared.translate(text, from: english, to: chinese) { result in
            switch result {
            case .success(let translatedResult):

                guard let translatedText = translatedResult.translations.first?.translatedText else {
                    completion(nil)
                    return
                }

                completion(translatedText)

            case .failure(_):
                completion(nil)
            }
        }

    }
    
    func convertSimplifiedToTraditional(_ text: String) -> String {
        let converter = try! ChineseConverter(options: [.traditionalize])
        let convertedText = converter.convert(text)
        
        return convertedText
    }
    
    func getTextType(_ text: String) -> TextType {
        // 去除前後空白字符
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 使用NLTokenizer來進行標記化
        let tokenizer = NLTokenizer(unit: .word)
        tokenizer.string = trimmedText
        var wordCount = 0
        
        tokenizer.enumerateTokens(in: trimmedText.startIndex..<trimmedText.endIndex) { tokenRange, _ in
            wordCount += 1
            return true
        }
        
        // 根據標記的數量來判斷
        if wordCount > 1 {
            return .sentence
        } else {
            return .word
        }
    }
    
    func getTextType(from selectMode: SelectMode) -> TextType {
        switch selectMode {
        case .word:
            return .word
        case .sentence:
            return .sentence
        }
    }
    
    private func getSaveDeck(_ cloze: Tag) -> CDDeck? {
        let decks = CoreDataManager.shared.getDecks()
        var deck: CDDeck? = nil
        let isWord = cloze.textType == .word
        
        if isWord {
            if let firstDeck = decks.first {
                deck = firstDeck
            }
            
        } else {
            if decks.count > 1 {
                deck = decks[1]
            }
        }
        
        guard let deck else { return nil }
        
        return deck
    }
    

    
    func rangeForMarkName(in article: FSArticle, markName: String) -> NSRange? {
        guard let ttsSynthesisResult = article.ttsSynthesisResult else {
            return nil
        }
        
        for timepoint in ttsSynthesisResult.timepoints {
            if timepoint.markName == markName {
                return timepoint.range
            }
        }
        
        return nil
    }
    
    func showPracticeAlert(presentViewController: UIViewController, waitAction: (()->())?, confirmAction: (()->())? ){
        let alertController = UIAlertController(title: nil, message: "進入練習", preferredStyle: .alert)
        
        // "稍等一下" 按鈕
        let waitAction = UIAlertAction(title: "稍等一下", style: .cancel) { _ in
            waitAction?()
        }
        
        // "確定" 按鈕
        let confirmAction = UIAlertAction(title: "確定", style: .default) { _ in
            // 在這裡處理按下 "確定" 按鈕後的動作
            confirmAction?()
        }
        
        alertController.addAction(waitAction)
        alertController.addAction(confirmAction)
        
        // 顯示 Alert
        
        presentViewController.present(alertController, animated: true)
    }
}

// MARK: SelectMode

extension WordSelectorViewControllerViewModel {
    mutating func changeSelectMode() {
        let currentSelectModeRawValue = selectMode.rawValue
        let isLastMode = currentSelectModeRawValue + 1 ==  SelectMode.allCases.count

        if isLastMode {
            selectMode = SelectMode(rawValue: 0)!
        } else {
            selectMode = SelectMode(rawValue: currentSelectModeRawValue + 1)!
        }
    }
}
