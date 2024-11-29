//
//  SDNote.swift
//  bLawPractice
//
//  Created by Morris Albers on 11/17/24.
//

import Foundation
import SwiftData

@available(iOS 17, *)
@Model
class SDNote: Codable {
    enum CodingKeys: CodingKey {
        case internalID
        case noteDateTime
        case noteNote
        case noteCategory
        case practice
        case representation
    }
    
    var internalID: Int = -1
    var practice: SDPractice?
    var representation: SDRepresentation?
    var noteDateTime: Date = Date.distantPast
    var noteNote: String = ""
    var noteCategory: String = ""

    init(internalID: Int, noteDateTime: Date, noteNote: String, noteCategory: String, representation: SDRepresentation?) {
        self.internalID = internalID
        self.noteDateTime = noteDateTime
        self.noteNote = noteNote
        self.noteCategory = noteCategory
        self.representation = representation
    }

    init(internalID: Int, noteDateTime: Date, noteNote: String, noteCategory: String) {
        self.internalID = internalID
        self.noteDateTime = noteDateTime
        self.noteNote = noteNote
        self.noteCategory = noteCategory
    }
    
    init() {
        self.internalID = -1
        self.noteDateTime = Date.distantPast
        self.noteNote = ""
        self.noteCategory = ""
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.internalID = container.decode(Int.self, forKey: .internalID)
        try self.noteDateTime = container.decode(Date.self, forKey: .noteDateTime)
        try self.noteNote = container.decode(String.self, forKey: .noteNote)
        try self.noteCategory = container.decode(String.self, forKey: .noteCategory)
        try self.practice = container.decodeIfPresent(SDPractice.self, forKey: .practice)
        try self.representation = container.decodeIfPresent(SDRepresentation.self, forKey: .representation)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(internalID, forKey: .internalID)
        try container.encode(noteDateTime, forKey: .noteDateTime)
        try container.encode(noteNote, forKey: .noteNote)
        try container.encode(noteCategory, forKey: .noteCategory)
        try container.encode(representation?.internalID, forKey: .practice)
    }
    
    @Transient var noteDate:String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let returnDate = formatter.string(from: self.noteDateTime)
        return returnDate
    }
    
    @Transient var noteTime:String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HHmm"
        let work = formatter.string(from: self.noteDateTime)
        return work
    }
    
    @Transient var printLine:String {
        let SinternalID: String = FormattingService.rjf(base: String(self.internalID), len: 5, zeroFill: true)
        let Sdate: String = DateService.dateDate2String(inDate:self.noteDateTime, short:true)
        let Stime: String = DateService.dateTime2String(inDate:self.noteDateTime)
        let Sreason: String = FormattingService.ljf(base: self.noteCategory, len: 10)
        let Snote: String = FormattingService.ljf(base: self.noteNote, len: 40)
        return "\(SinternalID) \(Sdate) \(Stime) \(Sreason) \(Snote)"
    }

}
