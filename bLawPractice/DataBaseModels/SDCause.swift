//
//  SDCause.swift
//  bLawPractice
//
//  Created by Morris Albers on 11/17/24.
//

import Foundation
import SwiftData
/*
     var practice: Practice?
     @Relationship(deleteRule: .nullify, inverse: \Note.cause) var notes: [Note]? = [Note]()

 */
@available(iOS 17, *)
@Model
class SDCause: Codable {
    enum CodingKeys: CodingKey {
        case internalID
        case causeNo
        case causeType
        case level
        case court
        case originalCharge
        case client
//        case practice
//        case representations
    }
    
    var internalID: Int = -1
    var causeNo: String?
    var causeType: String?           //  Appointed/Private/Family
    var level: String?
    var court: String?
    var originalCharge: String?
    var client:SDClient?
    var practice: SDPractice?
    var representations: [SDRepresentation]? = [SDRepresentation]()

    init(internalID: Int = -1, causeNo: String? = nil, causeType: String? = nil, level: String? = nil, court: String? = nil, originalCharge: String? = nil, client: SDClient? = nil, practice: SDPractice? = nil, representations: [SDRepresentation]? = nil) {
        self.internalID = internalID
        self.causeNo = causeNo
        self.causeType = causeType
        self.level = level
        self.court = court
        self.originalCharge = originalCharge
        self.client = client
        self.practice = practice
        self.representations = representations
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.internalID = container.decodeIfPresent(Int.self, forKey: .internalID) ?? -1
        try self.causeNo = container.decodeIfPresent(String.self, forKey: .causeNo)
        try self.causeType = container.decodeIfPresent(String.self, forKey: .causeType)
        try self.level = container.decodeIfPresent(String.self, forKey: .level)
        try self.court = container.decodeIfPresent(String.self, forKey: .court)
        try self.originalCharge = container.decodeIfPresent(String.self, forKey: .originalCharge)
        try self.client = container.decodeIfPresent(SDClient.self, forKey: .client)
        //        try self.practice = container.decodeIfPresent(SDPractice.self, forKey: .practice)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(internalID, forKey: .internalID)
        try container.encodeIfPresent(causeNo, forKey: .causeNo)
        try container.encodeIfPresent(causeType, forKey: .causeType)
        try container.encodeIfPresent(level, forKey: .level)
        try container.encodeIfPresent(court, forKey: .court)
        try container.encodeIfPresent(originalCharge, forKey: .originalCharge)
        try container.encodeIfPresent(client, forKey: .client)
    }
    
    @Transient var sortFormat1:String {
        let intID:Int = self.internalID
        let part1:String = String(intID)
        let part2:String = FormattingService.rjf(base: part1, len: 4, zeroFill: true)
        let part3:String = FormattingService.ljf(base: self.causeNo ?? "", len:9)
        let part4:String = FormattingService.ljf(base: self.originalCharge ?? "", len:12)
        let part5:String = part3 + "-" + part2 + "-" + part4
        let part6:String = FormattingService.ljf(base: part5, len:30)
        return part6
    }
    
    @Transient var sortFormat2:String {
        let intID:Int = self.internalID
        let part1:String = String(intID)
        let part2:String = FormattingService.rjf(base: part1, len: 4, zeroFill: true)
        let part3:String = FormattingService.ljf(base: self.causeNo ?? "", len:9)
        let part4:String = FormattingService.ljf(base: self.originalCharge ?? "", len:12)
        let part5 = part2 + "-" + part3 + "-" + part4
        let part6:String = FormattingService.ljf(base: part5, len:30)
        return part6
    }
    
    @Transient var causeDescr:String {
        let part3:String = FormattingService.ljf(base: self.causeNo ?? "", len:9)
        let part4:String = FormattingService.ljf(base: self.originalCharge ?? "", len:16)
        return part3 + " " + part4
    }
}
