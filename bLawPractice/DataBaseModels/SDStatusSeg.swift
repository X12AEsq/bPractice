//
//  SDStatusSeg.swift
//  bLawPractice
//
//  Created by Morris Albers on 11/17/24.
//

import Foundation
import SwiftData

@available(iOS 17, *)
@Model
class SDStatusSeg: Codable {
    enum CodingKeys: CodingKey {
        case internalID
        case representation
        case statusDate
        case practice
        case statusDescr
        case statusCode
        case statusDone
     }

    @Relationship(deleteRule: .noAction) var practice: SDPractice?
    var internalID: Int = -1
    var representation: SDRepresentation?
    var statusDate: Date?
    var statusDescr: String?
    var statusCode: String?
    var statusDone: Bool?
    
    init(internalID: Int, representation: SDRepresentation? = nil, statusDate: Date, practice: SDPractice?, statusDescr: String? = nil, statusCode: String? = nil, statusDone: Bool? = nil) {
        self.internalID = internalID
        self.representation = representation
        self.statusDate = statusDate
        self.practice = practice
        self.statusDescr = statusDescr
        self.statusCode = statusCode
        self.statusDone = statusDone
    }

    init() {
        self.internalID = -1
        self.representation = nil
        self.statusDate = Date.distantPast
        self.practice = nil
        self.statusDescr = ""
        self.statusCode = ""
        self.statusDone = false
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        internalID = try container.decode(Int.self, forKey: .internalID)
        representation = try container.decodeIfPresent(SDRepresentation.self, forKey: .representation)
        try self.statusDate = container.decode(Date.self, forKey: .statusDate)
        practice = try container.decodeIfPresent(SDPractice.self, forKey: .practice)
        statusDescr = try container.decodeIfPresent(String.self, forKey: .statusDescr)
        statusCode = try container.decodeIfPresent(String.self, forKey: .statusCode)
        statusDone = try container.decodeIfPresent(Bool.self, forKey: .statusDone)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(internalID, forKey: .internalID)
        try container.encode(representation, forKey: .representation)
        try container.encode(statusDate, forKey: .statusDate)
        try container.encode(practice, forKey: .practice)
        try container.encode(statusDescr, forKey: .statusDescr)
        try container.encode(statusCode, forKey: .statusCode)
        try container.encode(statusDone, forKey: .statusDone)
    }
}
