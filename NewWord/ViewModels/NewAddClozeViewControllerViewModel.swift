//
//  NewAddClozeViewControllerViewModel.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/7/1.
//

import UIKit
import MLKitTranslate
import OpenCC

struct NewAddClozeViewControllerViewModel {
    
    typealias CharacterIndex = Int
    
    
    struct CharacterGradientColor {
        
        struct Element: Comparable {
            let color: UIColor
            let location: Int
            let length: Int
            var heightFraction: Double = 0.0
            
            static func < (lhs: Element, rhs: Element) -> Bool {
                if lhs.location == rhs.location {
                    return lhs.length < rhs.length
                }
                return lhs.location < rhs.location
            }
        }
        
        var index: Int = 0
        
        var elements: [Int: [Element]] {
            didSet {
                for key in elements.keys {
                    elements[key]?.sort()
                }
            }
        }
    }
    
    var clozes: [NewAddCloze] = []
    
    mutating func getClozeNumber() -> Int {
        let clozeNumbers = clozes.map { $0.number }
        
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
    
    mutating func saveCloze(_ text: String) {
        var text = text
        
        let firstDeck = CoreDataManager.shared.getDecks().first!
        
        for i in 0..<clozes.count {
            let cloze = clozes[i]
            let offset = 6+String(cloze.number).count
            
            text = convertToContext(text, cloze)
            
            updateNSRange(with: cloze.range, offset: offset)
        }
        
        let context = CoreDataManager.shared.createContext(text)
        
        for cloze in clozes {
            let cloze = CoreDataManager.shared.createCloze(number: cloze.number, hint: "", clozeWord: cloze.cloze)
            cloze.context = context
            cloze.contextId = context.id
            
            let noteType = CoreDataManager.shared.createNoteNoteType(rawValue: 1)
            noteType.cloze = cloze
            
            let note = CoreDataManager.shared.createNote(noteType: noteType)
            
            CoreDataManager.shared.addCard(to: firstDeck, with: note)
        }
        
        CoreDataManager.shared.save()
    }
    
    func containsCloze(_ range: NSRange) -> Bool {
        for i in 0..<clozes.count {
            let currentCloze = clozes[i]
            
            let clozeExists = currentCloze.range == range
            
            if clozeExists {
                return true
            }
        }
        
        return false
    }
    
    mutating func removeCloze(_ range: NSRange) {
        
        for i in 0..<clozes.count {
            let currentCloze = clozes[i]
            
            let findCloze = currentCloze.range == range
            
            if findCloze {
                clozes.remove(at: i)
                break
            }
        }
    }
    
    mutating func convertToContext(_ text: String, _ cloze: NewAddCloze) -> String {
        let attributedText = NSMutableAttributedString(string: text)
        let frontCharacter = NSAttributedString(string: "{{C\(cloze.number):")
        let backCharacter = NSAttributedString(string: "}}")
        
        let backIndex = cloze.range.location + cloze.range.length
        let frontIndex = cloze.range.location
        
        attributedText.insert(backCharacter, at: backIndex)
        attributedText.insert(frontCharacter, at: frontIndex)
        
        return attributedText.string
    }
    
    mutating func updateNSRange(with comparedNSRange: NSRange, offset: Int) {
        for i in 0..<clozes.count {
            let currentCloze = clozes[i]
            
            if comparedNSRange.location < currentCloze.range.location {
                let location = currentCloze.range.location
                let length = currentCloze.range.length
                
                clozes[i].range = NSRange(location: location + offset, length: length)
            }
        }
    }
    
    mutating func appendCloze(_ cloze: NewAddCloze) {
        clozes.append(cloze)
    }
    
    func isWhitespace(_ string: String) -> Bool {
        let whitespaceCharacterSet = CharacterSet.whitespacesAndNewlines
        return string.trimmingCharacters(in: whitespaceCharacterSet).isEmpty
    }
    
    func getNSRanges() -> [NSRange] {
        return clozes.map { $0.range }
    }
    
    func getFlatRangeIndices() -> [CharacterIndex: [CharacterGradientColor.Element]] {
        var result: [CharacterIndex: [CharacterGradientColor.Element]] = [:]
        
        for i in 0..<clozes.count {
            let current = clozes[i]
            let nsRange = current.range
            
            for i in 0..<nsRange.length {
                let location = nsRange.location
                let index = location + i
                
                let newElement = CharacterGradientColor.Element(color: current.color, location: location, length: nsRange.length)
                
                if result[index] != nil {
                    result[index]!.append(newElement)
                } else {
                    result[index] = [newElement]
                }
            }
        }
        
        return result
    }
    
    // { characterPosition: [CharacterColor] }
    func createChracterGradientInformation() -> [[CharacterIndex: [CharacterGradientColor.Element]]] {
        let ranges = getFlatRangeIndices()
        
        let newMap = ranges.map { (key, value) in
            var elements = value
            
            var remainingHeightFraction: Double = 1.0
            var currentIndex = 0
            
            elements.sort()
            
            while currentIndex < elements.count {
                var overlappingCount = 0
                
                countOverlapping(currentIndex: currentIndex, elements: elements, count: &overlappingCount)
                
                let hasOverLapping = overlappingCount > 0
                
                if hasOverLapping {
                    let fraction = remainingHeightFraction / Double((overlappingCount+1))
                    
                    for _ in 0..<overlappingCount {
                        elements[currentIndex].heightFraction = fraction
                        remainingHeightFraction -= fraction
                        
                        currentIndex += 1
                    }
                    
                } else {
                    let isLastOne = currentIndex + 1 == elements.count
                    
                    if isLastOne {
                        elements[currentIndex].heightFraction = remainingHeightFraction
                    } else {
                        let fraction = remainingHeightFraction*0.1
                        elements[currentIndex].heightFraction = remainingHeightFraction
                        remainingHeightFraction -= fraction
                    }
                    
                    currentIndex += 1
                }
            }
            
            return [key: elements]
        }
        
        
        
        return newMap
    }
    
    private func countOverlapping(currentIndex: Int, elements: [CharacterGradientColor.Element], count: inout Int) {
        let current = elements[currentIndex]
        
        let hasNext = currentIndex + 1 < elements.count
        
        if hasNext {
            let next = elements[currentIndex+1]
            let isOverlapping = current.location == next.location
            
            if isOverlapping {
                count += 1
                countOverlapping(currentIndex: currentIndex+1, elements: elements, count: &count)
            }
        }
    }
    
    func translateEnglishToChinese(_ text: String, completion: @escaping (Result<String, Error>) -> Void) {
        let options = TranslatorOptions(sourceLanguage: .english, targetLanguage: .chinese)
        let englishChineseTranslator = Translator.translator(options: options)
        
        let conditions = ModelDownloadConditions(
            allowsCellularAccess: false,
            allowsBackgroundDownloading: true
        )
        
        englishChineseTranslator.downloadModelIfNeeded(with: conditions) { error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            englishChineseTranslator.translate(text) { translatedText, error in
                if let error = error {
                    completion(.failure(error))
                } else if let translatedText = translatedText {
                    completion(.success(translatedText))
                } else {
                    let unknownError = NSError(domain: "TranslationError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown error occurred"])
                    completion(.failure(unknownError))
                }
            }
        }
    }
    
    func convertSimplifiedToTraditional(_ text: String) -> String {
        let converter = try! ChineseConverter(options: [.traditionalize])
        let convertedText = converter.convert(text)
        
        return convertedText
    }
    
}
