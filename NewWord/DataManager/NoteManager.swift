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
    
    private init() {
        super.init(filename: NoteManager.filename)
        self.snapshot = readFromFile() ?? []
    }
    
    func addFakeNotes() {
        snapshot.append(contentsOf: Note.createFakeNotes())
        writeToFile()
    }
}
