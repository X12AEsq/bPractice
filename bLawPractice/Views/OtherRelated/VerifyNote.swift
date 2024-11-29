//
//  VerifyNote.swift
//  bLawPractice
//
//  Created by Morris Albers on 11/26/24.
//

import Foundation
class VerifyNote {
    public static func verifyNote(internalID: Int, noteDateTime: Date, noteNote: String, noteCategory: String, representation: SDRepresentation?)  -> ( errNo:Int, errDescr:String ) {
        if noteCategory == "UNK" || noteCategory == ""  {
            return (errNo:1, errDescr:"Must specify an note category")
        }
        return (errNo:0, errDescr: "")
    }
}
