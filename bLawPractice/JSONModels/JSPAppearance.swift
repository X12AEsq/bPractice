//
//  JSPAppearance.swift
//  bLawPractice
//
//  Created by Morris Albers on 11/17/24.
//

import Foundation
import SwiftUI
import SwiftData

class JSPAppearance: Identifiable, Codable, Hashable {
    static func == (lhs: JSPAppearance, rhs: JSPAppearance) -> Bool {
        lhs.internalID == rhs.internalID
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(internalID)
    }
    
    enum CodingKeys: CodingKey {
        case id
        case internalID
        case involvedRepresentation
        case appearDate
        case appearTime
        case appearReason
        case appearNote
    }

    var id: String
    var internalID: Int
//    var involvedClient: Int
//    var involvedCause: Int
    var involvedRepresentation: Int
    var appearDate: String
    var appearTime: String
    var appearReason: String
    var appearNote: String
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        internalID = try container.decode(Int.self, forKey: .internalID)
        involvedRepresentation = try container.decode(Int.self, forKey: .involvedRepresentation)
        appearDate = try container.decode(String.self, forKey: .appearDate)
        appearTime = try container.decode(String.self, forKey: .appearTime)
        appearReason = try container.decode(String.self, forKey: .appearReason)
        appearNote = try container.decode(String.self, forKey: .appearNote)
    }
 
    init (fsid:String, intid:Int, representation:Int, appeardate:String, appeartime:String, appearReason:String, appearnote:String) {
        self.id = fsid
        self.internalID = intid
//        self.involvedClient = client
//        self.involvedCause = cause
        self.involvedRepresentation = representation
        self.appearDate = appeardate
        self.appearTime = appeartime
        self.appearReason = appearReason
        self.appearNote = appearnote
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(internalID, forKey: .internalID)
        try container.encode(involvedRepresentation, forKey: .involvedRepresentation)
        try container.encode(appearDate, forKey: .appearDate)
        try container.encode(appearTime, forKey: .appearTime)
        try container.encode(appearNote, forKey: .appearNote)
        try container.encode(appearReason, forKey: .appearReason)
    }

    init() {
        self.id = ""
        self.internalID = 0
//        self.involvedClient = 0
//        self.involvedCause = 0
        self.involvedRepresentation = 0
        self.appearDate = ""
        self.appearTime = ""
        self.appearReason = ""
        self.appearNote = ""
    }
}

