//
//  NoteManager.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/5/15.
//

import Foundation


class NoteManager: DataManager<Note> {
    
    static let shared = NoteManager()
    
    static let filename = "notes.json"
    
    var notes: [Note] = []
    
    private init() {
        super.init(filename: NoteManager.filename)
        
        self.notes = readFromFile(filename: NoteManager.filename) ?? []
    }
    
    func addFakeNotes() {
        notes.append(contentsOf: Note.createFakeNotes())
        
        writeToFile(data: notes)
    }
}
