//
//  SDPractice.swift
//  bLawPractice
//
//  Created by Morris Albers on 11/17/24.
//

import Foundation
import SwiftData
/*
     @Relationship(deleteRule: .cascade, inverse: \SDClient.practice) var clients: [SDClient]? = [SDClient]()
     @Relationship(deleteRule: .cascade, inverse: \SDCause.practice) var causes: [SDCause]? = [SDCause]()
     @Relationship(deleteRule: .cascade) var representations: [SDRepresentation]? = [SDRepresentation]()
     @Relationship(deleteRule: .cascade, inverse: \SDAppearance.practice) var appearances: [SDAppearance]? = [SDAppearance]()
     @Relationship(deleteRule: .cascade, inverse: \SDNote.practice) var notes: [SDNote]? = [SDNote]()

 */
@Model
class SDPractice: Codable {
    enum CodingKeys: CodingKey {
        case internalId
        case addr1
        case addr2
        case city
        case name
        case shortName
        case state
        case testing
        case zip
        case clients
        case causes
        case representations
        case appearances
        case notes
    }
    
    var internalId:Int?
    var addr1: String?
    var addr2: String?
    var city: String?
    var name: String?
    var shortName: String?
    var state: String?
    var testing: Bool?
    var zip: String?
    @Relationship(deleteRule: .cascade, inverse: \SDClient.practice) var clients: [SDClient]? = [SDClient]()
    @Relationship(deleteRule: .cascade, inverse: \SDCause.practice) var causes: [SDCause]? = [SDCause]()
    @Relationship(deleteRule: .cascade) var representations: [SDRepresentation]? = [SDRepresentation]()
    @Relationship(deleteRule: .cascade, inverse: \SDAppearance.practice) var appearances: [SDAppearance]? = [SDAppearance]()
    @Relationship(deleteRule: .cascade, inverse: \SDNote.practice) var notes: [SDNote]? = [SDNote]()
    @Relationship(deleteRule: .cascade, inverse: \SDStatusSeg.practice) var statusSegs: [SDStatusSeg]? = [SDStatusSeg]()
//    var clients: [SDClient]?
//    var causes: [SDCause]?
    
    @Transient var isInTest:Bool {
        return ((self.testing) != nil)
    }

    init(addr1: String = "", addr2: String = "", city: String = "", internalID: Int = -1, name: String = "", shortName: String = "", state: String = "", testing: Bool = true, zip: String = "") {
        self.addr1 = addr1
        self.addr2 = addr2
        self.city = city
        self.internalId = internalID
        self.name = name
        self.shortName = shortName
        self.state = state
        self.testing = testing
        self.zip = zip
        self.clients = nil
        self.causes = nil
        self.representations = nil
        self.appearances = nil
        self.notes = nil
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.internalId = try container.decodeIfPresent(Int.self, forKey: .internalId)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.addr1 = try container.decodeIfPresent(String.self, forKey: .addr1)
        self.addr2 = try container.decodeIfPresent(String.self, forKey: .addr2)
        self.city = try container.decodeIfPresent(String.self, forKey: .city)
        self.state = try container.decodeIfPresent(String.self, forKey: .state)
        self.zip = try container.decodeIfPresent(String.self, forKey: .zip)
        self.shortName = try container.decodeIfPresent(String.self, forKey: .shortName)
        self.testing = try container.decodeIfPresent(Bool.self, forKey: .testing)
        self.clients = try container.decodeIfPresent([SDClient].self, forKey: .clients)
        self.causes = try container.decodeIfPresent([SDCause].self, forKey: .causes)
        self.representations = try container.decodeIfPresent([SDRepresentation].self, forKey: .representations)
        self.appearances = try container.decodeIfPresent([SDAppearance].self, forKey: .appearances)
        self.notes = try container.decodeIfPresent([SDNote].self, forKey: .notes)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(internalId, forKey: .internalId)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(addr1, forKey: .addr1)
        try container.encodeIfPresent(addr2, forKey: .addr2)
        try container.encodeIfPresent(city, forKey: .city)
        try container.encodeIfPresent(state, forKey: .state)
        try container.encodeIfPresent(zip, forKey: .zip)
        try container.encodeIfPresent(shortName, forKey: .shortName)
        try container.encodeIfPresent(testing, forKey: .testing)
        try container.encodeIfPresent(clients, forKey: .clients)
        try container.encodeIfPresent(causes, forKey: .causes)
        try container.encodeIfPresent(representations, forKey: .representations)
        try container.encodeIfPresent(appearances, forKey: .appearances)
        try container.encodeIfPresent(notes, forKey: .notes)
    }
}
