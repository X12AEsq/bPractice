//
//  VerifyCause.swift
//  bLawPractice
//
//  Created by Morris Albers on 11/27/24.
//

import Foundation
class VerifyCause {
    public static func verifyCause(internalID: Int, causeNo: String, causeType: String, level: String, court: String, originalCharge: String, client: SDClient?) -> ( errNo:Int, errDescr:String ) {
        if causeNo == "" {
            return (errNo:1, errDescr:"Cause must have a number")
        }
        if originalCharge == "" {
            return (errNo:1, errDescr:"Cause must include the charge")
        }
        if causeType == "UNK" || causeType == "" {
            return (errNo:2, errDescr:"Must specify a cause type")
        }
        if level == "UNK" || level == "" {
            return (errNo:3, errDescr:"Must specify a cause level")
        }
        if court == "UNK" || court == "" {
            return (errNo:4, errDescr:"Must specify a court")
        }
        if client == nil {
            return (errNo:5, errDescr:"Must specify a client")
        }
        return (errNo:0, errDescr: "")
    }
}
