//
//  JSPClient.swift
//  bLawPractice
//
//  Created by Morris Albers on 11/17/24.
//

import Foundation
import SwiftUI
import SwiftData
class JSPClient: Identifiable, Codable, Hashable {
    static func == (lhs: JSPClient, rhs: JSPClient) -> Bool {
            lhs.internalID == rhs.internalID
        }
    func hash(into hasher: inout Hasher) {
        hasher.combine(internalID)
    }
    var id: String
    var internalID: Int
    var lastName: String
    var firstName: String
    var middleName: String
    var suffix: String
    var addr1: String
    var addr2: String
    var city: String
    var state: String
    var zip: String
    var phone: String
    var note: String
    var miscDocketDate: Date
    var representation: [Int]

    init() {
        self.id = ""
        self.internalID = 0
        self.lastName = ""
        self.firstName = ""
        self.middleName = ""
        self.suffix = ""
        self.addr1 = ""
        self.addr2 = ""
        self.city = ""
        self.state = "TX"
        self.zip = ""
        self.phone = ""
        self.note = ""
        self.miscDocketDate = Date.distantPast
        self.representation = []
    }
    
    init (fsid:String, intid:Int, lastname:String, firstname: String, middlename: String, suffix: String, addr1: String, addr2:String, city: String, state: String, zip: String, phone: String, note: String, miscDocketDate:Date, representation: [Int]) {
        self.id = fsid
        self.internalID = intid
        self.lastName = lastname
        self.firstName = firstname
        self.middleName = middlename
        self.suffix = suffix
        self.addr1 = addr1
        self.addr2 = addr2
        self.city = city
        self.state = state
        self.zip = zip
        self.phone = phone
        self.note = note
        self.miscDocketDate = miscDocketDate
        self.representation = representation
    }
}

