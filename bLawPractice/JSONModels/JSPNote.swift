//
//  JSPNote.swift
//  bLawPractice
//
//  Created by Morris Albers on 11/17/24.
//

import Foundation
import SwiftUI
import SwiftData
class JSPNote: Identifiable, Codable, Hashable {
    static func == (lhs: JSPNote, rhs: JSPNote) -> Bool {
        lhs.internalID == rhs.internalID
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(internalID)
    }

    var id: String
    var internalID: Int
//    var involvedClient: Int
//    var involvedCause: Int
    var involvedRepresentation: Int
    var noteDate: String
    var noteTime: String
    var noteNote: String
    var noteCategory: String
    
    enum CodingKeys: CodingKey {
        case id, internalID, involvedRepresentation, noteDate, noteTime, noteNote, noteCategory
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        internalID = try container.decode(Int.self, forKey: .internalID)
        involvedRepresentation = try container.decode(Int.self, forKey: .involvedRepresentation)
        noteDate = try container.decode(String.self, forKey: .noteDate)
        noteTime = try container.decode(String.self, forKey: .noteTime)
        noteNote = try container.decode(String.self, forKey: .noteNote)
        noteCategory = try container.decode(String.self, forKey: .noteCategory)
    }
    
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(internalID, forKey: .internalID)
        try container.encode(involvedRepresentation, forKey: .involvedRepresentation)
        try container.encode(noteDate, forKey: .noteDate)
        try container.encode(noteTime, forKey: .noteTime)
        try container.encode(noteNote, forKey: .noteNote)
        try container.encode(noteCategory, forKey: .noteCategory)
    }
    
    init (fsid:String, intid:Int, representation:Int, notedate:String, notetime:String, notenote:String, notecat:String) {
        self.id = fsid
        self.internalID = intid
//        self.involvedClient = client
//        self.involvedCause = cause
        self.involvedRepresentation = representation
        self.noteDate = notedate
        self.noteTime = notetime
        self.noteNote = notenote
        self.noteCategory = notecat
    }

    init() {
        self.id = ""
        self.internalID = 0
//        self.involvedClient = 0
//        self.involvedCause = 0
        self.involvedRepresentation = 0
        self.noteDate = ""
        self.noteTime = ""
        self.noteNote = ""
        self.noteCategory = ""
    }
}

