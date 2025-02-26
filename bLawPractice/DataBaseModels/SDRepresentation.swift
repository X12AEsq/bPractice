//
//  SDRepresentation.swift
//  bLawPractice
//
//  Created by Morris Albers on 11/17/24.
//

import Foundation
import SwiftData
/*
 @Relationship(deleteRule: .nullify) var client: Client?
 @Relationship(deleteRule: .nullify) var cause: Cause?
 @Relationship(deleteRule: .cascade) var appearances: [Appearance]? = [Appearance]()
 @Relationship(deleteRule: .cascade) var notes: [Note]? = [Note]()
 @Relationship(deleteRule: .nullify) var practice: Practice?

 Each representation must have only one client; a client may have many representations
 */

@available(iOS 17, *)
@Model
class SDRepresentation: Codable {
    enum CodingKeys: CodingKey {
        case internalID
        case active
        case assignedDateTime
        case dispositionDateTime
        case dispositionType
        case dispositionAction
        case primaryCategory
        case practice
        case client
        case cause
        case appearances
        case statussegs
    }
    
    var internalID: Int = -1
    @Relationship(deleteRule: .nullify) var client: SDClient?
    @Relationship(deleteRule: .nullify) var cause: SDCause?
    @Relationship(deleteRule: .cascade) var appearances: [SDAppearance]? = [SDAppearance]()
    @Relationship(deleteRule: .cascade) var notes: [SDNote]? = [SDNote]()
    @Relationship(deleteRule: .cascade) var statussegs: [SDStatusSeg]? = [SDStatusSeg]()
    @Relationship(deleteRule: .nullify) var practice: SDPractice?
    var active: Bool = false               // Open,Closed
    var assignedDateTime: Date = Date.distantPast
    var dispositionDateTime: Date = Date.distantPast
    var dispositionType: String = ""     // PB, DISM, OTH ...
    var dispositionAction:String = ""    // PROB, DEF, PTD, C ...
    var primaryCategory:String = ""     // ORIG, MTA, MTR, ...
    
    init(internalID: Int, active: Bool, assignedDate: Date, dispositionDate: Date, dispositionType: String, dispositionAction: String, primaryCategory: String, cause:SDCause? = nil, client:SDClient? = nil, appearances:[SDAppearance] = [SDAppearance](), notes:[SDNote] = [SDNote](), statussegs:[SDStatusSeg]? = nil, practice:SDPractice? = nil) {
        self.internalID = internalID
        self.active = active
        self.assignedDateTime = assignedDate
        self.dispositionDateTime = dispositionDate
        self.dispositionType = dispositionType
        self.dispositionAction = dispositionAction
        self.primaryCategory = primaryCategory
        self.client = client
        self.cause = cause
        self.appearances = appearances
        self.notes = notes
        self.practice = practice
        self.statussegs = statussegs
    }
    
    init() {
        self.internalID = -1
        self.active = true
        self.assignedDateTime = Date.distantPast
        self.dispositionDateTime = Date.distantFuture
        self.dispositionType = ""
        self.dispositionAction = ""
        self.primaryCategory = ""
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.internalID = try container.decode(Int.self, forKey: .internalID)
        self.active = try container.decode(Bool.self, forKey: .active)
        self.assignedDateTime = try container.decode(Date.self, forKey: .assignedDateTime)
        self.dispositionType = try container.decode(String.self, forKey: .dispositionType)
        self.dispositionAction = try container.decode(String.self, forKey: .dispositionAction)
        self.dispositionDateTime = try container.decode(Date.self, forKey: .dispositionDateTime)
        self.practice = try container.decode(SDPractice.self, forKey: .practice)
        self.client = try container.decode(SDClient.self, forKey: .client)
        self.cause = try container.decode(SDCause.self, forKey: .cause)
        self.appearances = try container.decode([SDAppearance].self, forKey: .appearances)
        self.statussegs = try container.decode([SDStatusSeg].self, forKey: .statussegs)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(internalID, forKey: .internalID)
        try container.encode(active, forKey: .active)
        try container.encode(dispositionType, forKey: .dispositionType)
        try container.encode(dispositionAction, forKey: .dispositionAction)
        try container.encode(dispositionDateTime, forKey: .dispositionDateTime)
        try container.encode(primaryCategory, forKey: .primaryCategory)
        try container.encode(assignedDateTime, forKey: .assignedDateTime)
        try container.encode(practice, forKey: .practice)
        try container.encode(client, forKey: .client)
        try container.encode(cause, forKey: .cause)
        try container.encode(appearances, forKey: .appearances)
        try container.encode(statussegs, forKey: .statussegs)
    }
        
    @Transient var assignedDate:String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let returnDate = formatter.string(from: self.assignedDateTime)
        return returnDate
    }
    
    @Transient var dispositionDate:String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let returnDate = formatter.string(from: self.dispositionDateTime)
        return returnDate
    }
    
    @Transient var fullName:String {
        if let workClient = self.client {
            return workClient.fullName
        } else {
            return "No Client Name"
        }
    }
    
    @Transient var causeNo:String {
        if let workCause = self.cause {
            return workCause.causeNo ?? "No Cause Number"
        } else {
            return "No Cause Number"
        }
    }
    
    @Transient var causeCharge:String {
        if let workCause = self.cause {
            return workCause.originalCharge ?? "No Charge"
        } else {
            return "No Charge"
        }
    }
    
    @Transient var repActiveString:String {
        if self.active {
            return "Active"
        } else {
            return "Inactive"
        }
    }
}
