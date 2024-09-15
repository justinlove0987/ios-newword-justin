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

    var startTime: Date?
    var timer: DispatchSourceTimer?

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
    
    var tags: [CDUserGeneratedContextTag] = []
    
    var selectMode: SelectMode = .word
    
    var currentSelectedRange: NSRange?
    
    var translationPairs: [TranslationPair] = []

    mutating func getClozeNumber() -> Int {
        let clozeNumbers = tags.map { Int($0.number) }
        
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

    func getUpdatedRange(range: NSRange, offset: Int) -> NSRange? {
        let location = range.location

        for tag in tags {
            guard let currentRange = tag.range else { return nil }

            let currentLocation = currentRange.location
            let isSameLocation = location == currentLocation

            if isSameLocation {
                return range
            }
        }

        return NSRange(location: range.location+offset, length: range.length)
    }
    
    mutating func removeAllTags(in text: String) -> String? {
        var text = text
        let uniqueClozeIndices = getUniqueLocationClozeIndices()

        for i in uniqueClozeIndices {
            let tag = tags[i]
            let offset = -1
            
            guard let range = tag.range else { return nil }
            
            let tagLocation = range.location-1
            
            let tagRange = NSRange(location: tagLocation, length: 1)
            
            if let tagIndex = tag.getTagIndex(in: text) {
                text.remove(at: tagIndex)
                updateTagNSRanges(with: tagRange, offset: offset)
            }
        }
        
        return text
    }

    mutating func saveTag(_ text: String) {
        let context = CoreDataManager.shared.createContext(text)
        
        for i in 0..<tags.count {
            let tag = tags[i]
            
            guard let range = tag.range else { return }
            guard let text = tag.text else { return }
            
            guard let word = textInRange(text: text, range: range),
                  let deck = getSaveDeck(tag) else {
                continue
            }
            
            let newCloze = CoreDataManager.shared.createCloze(number: Int(tag.number), hint: "", clozeWord: text)

            newCloze.context = context
            newCloze.contextId = context.id
            newCloze.clozeWord = word
            newCloze.location = Int64(range.location)
            newCloze.length = Int64(range.length)
            newCloze.hint = tag.translation
            
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
    
    func containsTag(textType: ContextType, range: NSRange) -> Bool {
        for i in 0..<tags.count {
            let currentTag = tags[i]
            
            let tagExists = currentTag.isEqualTo(textType: textType, range: range)
            
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
    
    mutating func removeTag(_ range: NSRange){
        for i in 0..<tags.count {
            let currentTag = tags[i]

            let findTag = currentTag.range == range
            
            if findTag {
                CoreDataManager.shared.deleteEntity(currentTag)
                tags.remove(at: i)
                break
            }
        }
    }

    func hasDuplicateTagLocations(with range: NSRange) -> Bool {
        for i in 0..<tags.count {
            let tag = tags[i]
            guard let crrentRange = tag.range else { return false }
            let currentLocation = crrentRange.location
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

    func updateAudioRange(tagPosition: Int, adjustmentOffset: Int, article: CDPracticeArticle?) {
        let userGeneratedTimepoints = CoreDataManager.shared.getUserGeneratedTimepoints(from: article)

        for i in 0..<userGeneratedTimepoints.count {
            let timepoint = userGeneratedTimepoints[i]

            guard let range = timepoint.range else { continue }

            let isGreaterThanTagPosition = range.location >= tagPosition

            if isGreaterThanTagPosition {
                userGeneratedTimepoints[i].rangeLocation += Int64(adjustmentOffset)
            }
        }
    }

    mutating func updateTagNSRanges(with newNSRange: NSRange, offset: Int) {
        for i in 0..<tags.count {
            let tag = tags[i]

            guard let range = tag.range else { return }

            if newNSRange.location == range.location {
                return
            }

            let newLocation = newNSRange.location
            let currentLocation = range.location
            let currentLength = range.length

            if newLocation < currentLocation {
                tags[i].revisedRangeLocation = currentLocation.toInt64 + offset.toInt64

            } else if newLocation > currentLocation && newLocation < currentLocation + currentLength {
                tags[i].revisedRangeLength = currentLength.toInt64 + offset.toInt64
            }
        }
    }

    func createNewTag(number: Int, 
                        text: String,
                        range: NSRange,
                        textType: ContextType,
                      hint: String) -> CDUserGeneratedContextTag {

        let tagColor: UIColor = selectMode == .sentence ? UIColor.tagBlue : UIColor.tagGreen
        let cotentColor: UIColor = selectMode == .sentence ? UIColor.clozeBlueText: UIColor.textGreen
        
        let tag = CoreDataManager.shared.createEntity(ofType: CDUserGeneratedContextTag.self)
        
        tag.number = number.toInt64
        tag.originalRangeLength = 0
        tag.originalRangeLocation = 0
        tag.revisedRangeLength = range.length.toInt64
        tag.revisedRangeLocation = range.location.toInt64
        tag.tagColor = tagColor.toData()
        tag.contentColor = cotentColor.toData()
        tag.text = text
        tag.translation = hint
        tag.typeRawValue = textType.rawValue.toInt64

        return tag
    }

    mutating func appendTag(_ tag: CDUserGeneratedContextTag) {
        tags.append(tag)
    }
    
    func getUniqueLocationClozeIndices() -> [Int] {
        var uniqueLocations: Set<Int> = .init()
        var indices: [Int] = []

        for i in 0..<tags.count {
            let currentCloze = tags[i]
            guard let range = currentCloze.range else { return [] }
            let location = range.location
            
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
        return tags.map { $0.range! }
    }

    func createColoredText() -> ColoredText {
        var result = ColoredText(coloredCharacters: [:])

        for i in 0..<tags.count {
            let tag = tags[i]
            let nsRange = tag.range

            guard let location = nsRange?.location,
                  let length = nsRange?.length,
                  let tagColorData = tag.tagColor,
                  let tagColor = UIColor.fromData(tagColorData),
                  let contentColorData = tag.contentColor,
                  let contentColor = UIColor.fromData(contentColorData)
            else { continue }


            let newSegment = ColorSegment(tagColor: tagColor,
                                          contentColor: contentColor,
                                          clozeLocation: location,
                                          clozeLength: length,
                                          tagNumber: Int(tag.number))


            for i in 0..<length {
                let index = location + i
                let isFirstIndex = location == index
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
    
    mutating func calculateColoredTextHeightFraction() -> ColoredText {

        startTimer()

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
    
    func getTextType(_ text: String) -> ContextType {
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
    
    func getTextType(from selectMode: SelectMode) -> ContextType {
        switch selectMode {
        case .word:
            return .word
        case .sentence:
            return .sentence
        }
    }
    
    private func getSaveDeck(_ cloze: CDUserGeneratedContextTag) -> CDDeck? {
        let decks = CoreDataManager.shared.getDecks()
        var deck: CDDeck? = nil
        let isWord = cloze.type == .word
        
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


    
    func rangeForMarkName(in article: CDPracticeArticle, markName: String) -> NSRange? {
        let userGeneratedTimepoints = CoreDataManager.shared.getUserGeneratedTimepoints(from: article)

        for timepoint in userGeneratedTimepoints {
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

    mutating func startTimer() {
        startTime = Date() // 紀錄開始時間
        timer = DispatchSource.makeTimerSource() // 創建計時器
        timer?.schedule(deadline: .now(), repeating: 1) // 每秒觸發一次
        timer?.setEventHandler {
            // 計時器在每次觸發時可以執行其他邏輯
        }
        timer?.resume() // 開始計時
    }

    func printElapsedSeconds() {
        guard let startTime = startTime else {
            print("計時器尚未開始")
            return
        }

        let elapsed = Date().timeIntervalSince(startTime) // 計算經過的秒數
        let formattedElapsed = String(format: "%.2f", elapsed) // 格式化小數點後兩位
        print("已經經過 \(formattedElapsed) 秒")
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
