//
//  JSPackage.swift
//  bLawPractice
//
//  Created by Morris Albers on 11/17/24.
//

import Foundation
import SwiftUI
import SwiftData

class JSPackage: Identifiable, Codable, Hashable {
    static func == (lhs: JSPackage, rhs: JSPackage) -> Bool {
        lhs.JSPId == rhs.JSPId
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(JSPId)
    }
    
    var JSPId:Int = 0
    var JSPCauses:[JSPCause] = [JSPCause]()
    var JSPClients:[JSPClient] = [JSPClient]()
    var JSPRepresentations:[JSPRepresentation] = [JSPRepresentation]()
    var JSPPractices:[JSPPractice] = [JSPPractice]()
    
    init() {
        self.JSPId = 0
        self.JSPCauses = [JSPCause]()
        self.JSPClients = [JSPClient]()
        self.JSPRepresentations = [JSPRepresentation]()
        self.JSPPractices = [JSPPractice]()
    }
    
    enum CodingKeys: CodingKey {
        case JSPId
        case JSPCauses
        case JSPClients
        case JSPRepresentations
        case JSPPractices
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        JSPId = try container.decode(Int.self, forKey: .JSPId)
        JSPCauses = try container.decode([JSPCause].self, forKey: .JSPCauses)
        JSPClients = try container.decode([JSPClient].self, forKey: .JSPClients)
        JSPRepresentations = try container.decode([JSPRepresentation].self, forKey: .JSPRepresentations)
        JSPPractices = try container.decode([JSPPractice].self, forKey: .JSPPractices)
    }
    
}
