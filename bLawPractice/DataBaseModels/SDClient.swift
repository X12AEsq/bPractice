//
//  SDClient.swift
//  bLawPractice
//
//  Created by Morris Albers on 11/17/24.
//

import Foundation
import SwiftData
/*
 var representations: [Representation]? = [Representation]()      // Firebase Integer
 @Relationship(deleteRule: .nullify, inverse: \Appearance.client) var appearances: [Appearance]? = [Appearance]()
 @Relationship(deleteRule: .nullify, inverse: \Cause.client) var causes: [Cause]? = [Cause]()
 @Relationship(deleteRule: .nullify, inverse: \Note.client) var notes: [Note]? = [Note]()
 @Relationship(deleteRule: .nullify) var practice: SDPractice?

 */
@available(iOS 17, *)
@Model
class SDClient: Codable {
    enum CodingKeys: CodingKey {
        case internalID
        case lastName
        case firstName
        case middleName
        case suffix
        case addr1
        case addr2
        case city
        case state
        case zip
        case phone
        case note
        case miscDocketDate
        case practice
        case representations
    }
    
    var internalID: Int?
    var lastName: String?
    var firstName: String?
    var middleName: String?
    var suffix: String?
    var addr1: String?
    var addr2: String?
    var city: String?
    var state: String?
    var zip: String?
    var phone: String?
    var note: String?
    var miscDocketDate: Date?
    var representations: [SDRepresentation]? = [SDRepresentation]()
    @Relationship(deleteRule: .nullify, inverse: \SDCause.client) var causes: [SDCause]? = [SDCause]()
    @Relationship(deleteRule: .nullify) var practice: SDPractice?

    @Transient var fullName:String {
        return AssemblePersonName.assembleName(firstName: self.firstName ?? "", middleName: self.middleName ?? "", lastName: self.lastName ?? "", suffix: self.suffix ?? "")
    }
    
    @Transient var formattedAddress:String {
        return AssembleFormattedAddress.assembleAddress(addr1: self.addr1 ?? "", addr2: self.addr2 ?? "", city: self.city ?? "", state: self.state ?? "", zip: self.zip ?? "")
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.internalID = container.decodeIfPresent(Int.self, forKey: .internalID)
        try self.lastName = container.decodeIfPresent(String.self, forKey: .lastName)
        try self.firstName = container.decodeIfPresent(String.self, forKey: .firstName)
        try self.middleName = container.decodeIfPresent(String.self, forKey: .middleName)
        try self.suffix = container.decodeIfPresent(String.self, forKey: .suffix)
        try self.addr1 = container.decodeIfPresent(String.self, forKey: .addr1)
        try self.addr2 = container.decodeIfPresent(String.self, forKey: .addr2)
        try self.city = container.decodeIfPresent(String.self, forKey: .city)
        try self.state = container.decodeIfPresent(String.self, forKey: .state)
        try self.zip = container.decodeIfPresent(String.self, forKey: .zip)
        try self.phone = container.decodeIfPresent(String.self, forKey: .phone)
        try self.note = container.decodeIfPresent(String.self, forKey: .note)
        try self.miscDocketDate = container.decodeIfPresent(Date.self, forKey: .miscDocketDate)
        try self.practice = container.decodeIfPresent(SDPractice.self, forKey: .practice)
        try self.representations = container.decodeIfPresent([SDRepresentation].self, forKey: .representations)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.internalID, forKey: .internalID)
        try container.encodeIfPresent(self.lastName, forKey: .lastName)
        try container.encodeIfPresent(self.firstName, forKey: .firstName)
        try container.encodeIfPresent(self.middleName, forKey: .middleName)
        try container.encodeIfPresent(self.suffix, forKey: .suffix)
        try container.encodeIfPresent(self.addr1, forKey: .addr1)
        try container.encodeIfPresent(self.addr2, forKey: .addr2)
        try container.encodeIfPresent(self.city, forKey: .city)
        try container.encodeIfPresent(self.state, forKey: .state)
        try container.encodeIfPresent(self.zip, forKey: .zip)
        try container.encodeIfPresent(self.phone, forKey: .phone)
        try container.encodeIfPresent(self.note, forKey: .note)
        try container.encodeIfPresent(self.miscDocketDate, forKey: .miscDocketDate)
        try container.encodeIfPresent(self.practice, forKey: .practice)
        try container.encodeIfPresent(self.representations, forKey: .representations)
    }
    
    init(internalID: Int = -1, lastName: String = "", firstName: String = "", middleName: String = "", suffix: String = "", addr1: String = "", addr2: String = "", city: String = "", state: String = "", zip: String = "", phone: String = "", note: String = "", miscDocketDate: Date = Date()) {
        self.internalID = internalID
        self.lastName = lastName
        self.firstName = firstName
        self.middleName = middleName
        self.suffix = suffix
        self.addr1 = addr1
        self.addr2 = addr2
        self.city = city
        self.state = state
        self.zip = zip
        self.phone = phone
        self.note = note
        self.miscDocketDate = miscDocketDate
//        self.representations = representations
    }
    
    init(internalID: Int = -1, lastName: String = "", firstName: String = "", middleName: String = "", suffix: String = "", addr1: String = "", addr2: String = "", city: String = "", state: String = "", zip: String = "", phone: String = "", note: String = "", miscDocketDate: Date = Date(), practice: SDPractice) {
        self.internalID = internalID
        self.lastName = lastName
        self.firstName = firstName
        self.middleName = middleName
        self.suffix = suffix
        self.addr1 = addr1
        self.addr2 = addr2
        self.city = city
        self.state = state
        self.zip = zip
        self.phone = phone
        self.note = note
        self.miscDocketDate = miscDocketDate
        self.representations = [SDRepresentation]()
        self.causes = [SDCause]()
        self.practice = practice
    }
}
