//
//  JSPPractice.swift
//  bLawPractice
//
//  Created by Morris Albers on 11/17/24.
//

import Foundation
import SwiftUI
import SwiftData
class JSPPractice: Identifiable, Codable, Hashable {
    static func == (lhs: JSPPractice, rhs: JSPPractice) -> Bool {
        lhs.internalId == rhs.internalId
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(internalId)
    }
    
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
    }
    
    var internalId:Int
    var addr1: String
    var addr2: String
    var city: String
    var name: String
    var shortName: String
    var state: String
    var testing: Bool
    var zip: String
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.internalId = try container.decode(Int.self, forKey: .internalId)
        self.addr1 = try container.decode(String.self, forKey: .addr1)
        self.addr2 = try container.decode(String.self, forKey: .addr2)
        self.city = try container.decode(String.self, forKey: .city)
        self.name = try container.decode(String.self, forKey: .name)
        self.shortName = try container.decode(String.self, forKey: .shortName)
        self.state = try container.decode(String.self, forKey: .state)
        self.testing = try container.decode(Bool.self, forKey: .testing)
        self.zip = try container.decode(String.self, forKey: .zip)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(internalId, forKey: .internalId)
        try container.encode(addr1, forKey: .addr1)
        try container.encode(addr2, forKey: .addr2)
        try container.encode(city, forKey: .city)
        try container.encode(name, forKey: .name)
        try container.encode(shortName, forKey: .shortName)
        try container.encode(state, forKey: .state)
        try container.encode(testing, forKey: .testing)
        try container.encode(zip, forKey: .zip)
    }
    
    init (internalId: Int, addr1: String, addr2: String, city: String, name: String, shortName: String, state: String, testing: Bool, zip: String) {
        self.internalId = internalId
        self.addr1 = addr1
        self.addr2 = addr2
        self.city = city
        self.name = name
        self.shortName = shortName
        self.state = state
        self.testing = testing
        self.zip = zip
    }
    
    init() {
        self.internalId = -1
        self.addr1 = ""
        self.addr2 = ""
        self.city = ""
        self.name = ""
        self.shortName = ""
        self.state = ""
        self.testing = false
        self.zip = ""
    }
}
