//
//  NewAddClozeViewControllerViewModel.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/7/1.
//

import Foundation


struct NewAddClozeViewControllerViewModel {
    
    var clozeNumbers: Set<Int> = .init()
    
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
}
