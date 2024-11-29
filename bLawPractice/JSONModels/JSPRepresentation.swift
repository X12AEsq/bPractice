//
//  JSPRepresentation.swift
//  bLawPractice
//
//  Created by Morris Albers on 11/17/24.
//

import Foundation
import SwiftUI
import SwiftData
class JSPRepresentation: Identifiable, Codable, Hashable {
    static func == (lhs: JSPRepresentation, rhs: JSPRepresentation) -> Bool {
            lhs.internalID == rhs.internalID
        }
    func hash(into hasher: inout Hasher) {
        hasher.combine(internalID)
    }
    var id: String
    var internalID: Int
    var involvedClient: Int
    var involvedCause: Int
    var involvedAppearances: [Int]
    var involvedNotes: [Int]
    var active: Bool
    var assignedDate: Date
    var dispositionDate: Date
    var dispositionType: String
    var dispositionAction:String
    var primaryCategory:String
    var appearanceList: [JSPAppearance]
    var noteList: [JSPNote]
    
    enum CodingKeys: CodingKey {
        case id
        case internalID
        case involvedClient
        case involvedCause
        case involvedAppearances
        case involvedNotes
        case active
        case assignedDate
        case dispositionDate
        case dispositionAction
        case dispositionType
        case primaryCategory
        case appearanceList
        case noteList
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        internalID = try container.decode(Int.self, forKey: .internalID)
        involvedClient = try container.decode(Int.self, forKey: .involvedClient)
        involvedCause = try container.decode(Int.self, forKey: .involvedCause)
        involvedNotes = try container.decode([Int].self, forKey: .involvedNotes)
        involvedAppearances = try container.decode([Int].self, forKey: .involvedAppearances)
        active = try container.decode(Bool.self, forKey: .active)
        assignedDate = try container.decode(Date.self, forKey: .assignedDate)
        dispositionDate = try container.decode(Date.self, forKey: .dispositionDate)
        dispositionType = try container.decode(String.self, forKey: .dispositionType)
        dispositionAction = try container.decode(String.self, forKey: .dispositionAction)
        primaryCategory = try container.decode(String.self, forKey: .primaryCategory)
        appearanceList = try container.decode([JSPAppearance].self, forKey: .appearanceList)
        noteList = try container.decode([JSPNote].self, forKey: .noteList)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(internalID, forKey: .internalID)
        try container.encode(involvedClient, forKey: .involvedClient)
        try container.encode(involvedCause, forKey: .involvedCause)
        try container.encode(involvedAppearances, forKey: .involvedAppearances)
        try container.encode(involvedNotes, forKey: .involvedNotes)
        try container.encode(active, forKey: .active)
        try container.encode(assignedDate, forKey: .assignedDate)
        try container.encode(dispositionDate, forKey: .dispositionDate)
        try container.encode(dispositionType, forKey: .dispositionType)
        try container.encode(dispositionAction, forKey: .dispositionAction)
        try container.encode(primaryCategory, forKey: .primaryCategory)
        try container.encode(appearanceList, forKey: .appearanceList)
        try container.encode(noteList, forKey: .noteList)
    }
    
    init (fsid:String, intid:Int, client:Int, cause:Int, appearances:[Int], notes:[Int], active:Bool, assigneddate:Date, dispositiondate:Date, dispositionaction:String, dispositiontype:String, primarycategory:String) {
        self.id = fsid
        self.internalID = intid
        self.involvedClient = client
        self.involvedCause = cause
        self.involvedAppearances = appearances
        self.involvedNotes = notes
        self.active = active
        self.assignedDate = assigneddate
        self.dispositionDate = dispositiondate
        self.dispositionAction = dispositionaction
        self.dispositionType = dispositiontype
        self.primaryCategory = primarycategory
        self.appearanceList = []
        self.noteList = []
    }

    init() {
        self.id = ""
        self.internalID = 0
        self.involvedClient = 0
        self.involvedCause = 0
        self.involvedAppearances = []
        self.involvedNotes = []
        self.active = false
        self.assignedDate = Date.distantPast
        self.dispositionDate = Date.distantPast
        self.dispositionType = "PB"
        self.dispositionAction = "DEF"
        self.primaryCategory = "ORIG"
        self.appearanceList = []
        self.noteList = []
    }
}

