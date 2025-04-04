//
//  VerifyAppearance.swift
//  bLawPractice
//
//  Created by Morris Albers on 11/26/24.
//

import Foundation
class VerifyAppearance {
    public static func verifyAppearance(internalID: Int, appearDateTime: Date, appearNote: String, appearReason: String, representation: SDRepresentation?)  -> ( errNo:Int, errDescr:String ) {
        if appearReason == "UNK" || appearReason == ""  {
            return (errNo:1, errDescr:"Must specify an appearance reason")
        }
        if internalID < 1 {
            return (errNo:2, errDescr:"Must specify a valid internal ID")
        }
        return (errNo:0, errDescr: "")
    }
}
