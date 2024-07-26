//
//  Note.swift
//  NewWord
//
//  Created by justin on 2024/4/12.
//

import Foundation

struct Note: Codable, Hashable {
    
    let id: String
    let noteType: OldNoteType
    
    static func == (lhs: Note, rhs: Note) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Note {
    static func createFakeNotes() -> [Note] {
        let sentences = [
            ["Life", "is", "like", "riding", "a", "bicycle", ".", "To", "keep", "your", "balance", ",", "you", "must", "keep", "moving", "."],
            ["Genius", "is", "one", "percent", "inspiration", "and", "ninety-nine", "percent", "perspiration", "."]
        ]
        
        let sentenceCloze1 = SentenceCloze(clozeWord: Word(text: "like", chinese: "像是我"), sentence: sentences[0])
        let sentenceCloze2 = SentenceCloze(clozeWord: Word(text: "inspiration", chinese: "激發"), sentence: sentences[1])
        
        let note1 = Note(id: UUID().uuidString, noteType: .sentenceCloze(sentenceCloze1))
        let note2 = Note(id: UUID().uuidString, noteType: .sentenceCloze(sentenceCloze2))
        
        return [note1, note2]
    }
}


