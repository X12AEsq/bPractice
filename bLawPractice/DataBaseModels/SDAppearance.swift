//
//  SDAppearance.swift
//  bLawPractice
//
//  Created by Morris Albers on 11/17/24.
//

import Foundation
import SwiftData

@available(iOS 17, *)
@Model
class SDAppearance: Codable {
    enum CodingKeys: CodingKey {
        case internalID
        case appearDateTime
        case appearNote
        case appearReason
        case practice
        case representation
    }
    
    var internalID: Int = -1
    var practice: SDPractice?
    var representation: SDRepresentation?
    var appearDateTime: Date = Date.distantPast
    var appearNote: String = ""
    var appearReason: String = ""
    
    init(internalID: Int, appearDateTime: Date, appearNote: String, appearReason: String, representation: SDRepresentation?) {
        self.internalID = internalID
        self.appearDateTime = appearDateTime
        self.appearNote = appearNote
        self.appearReason = appearReason
        self.representation = representation
    }
    
    init() {
        self.internalID = -1
        self.appearDateTime = Date.distantPast
        self.appearNote = ""
        self.appearReason = ""
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.internalID = container.decode(Int.self, forKey: .internalID)
        try self.appearDateTime = container.decode(Date.self, forKey: .appearDateTime)
        try self.appearNote = container.decode(String.self, forKey: .appearNote)
        try self.appearReason = container.decode(String.self, forKey: .appearReason)
        try self.practice = container.decodeIfPresent(SDPractice.self, forKey: .practice)
        try self.representation = container.decodeIfPresent(SDRepresentation.self, forKey: .representation)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(internalID, forKey: .internalID)
        try container.encode(appearDateTime, forKey: .appearDateTime)
        try container.encode(appearNote, forKey: .appearNote)
        try container.encode(appearReason, forKey: .appearReason)
        try container.encode(practice, forKey: .practice)
        try container.encode(representation, forKey: .representation)
    }

    @Transient var appearDate:String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let returnDate = formatter.string(from: self.appearDateTime)
        return returnDate
    }
    
    @Transient var appearTime:String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HHmm"
        let work = formatter.string(from: self.appearDateTime)
        return work
    }
    
    @Transient var printLine:String {
        let SinternalID: String = FormattingService.rjf(base: String(self.internalID), len: 5, zeroFill: true)
        let Sdate: String = DateService.dateDate2String(inDate:self.appearDateTime, short:true)
        let Stime: String = DateService.dateTime2String(inDate:self.appearDateTime)
        let Sreason: String = FormattingService.ljf(base: self.appearReason, len: 10)
        let Snote: String = FormattingService.ljf(base: self.appearNote, len: 40)
        return "\(SinternalID) \(Sdate) \(Stime) \(Sreason) \(Snote)"
    }
}
