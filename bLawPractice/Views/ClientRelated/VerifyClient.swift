//
//  VerifyClient.swift
//  bLawPractice
//
//  Created by Morris Albers on 11/19/24.
//

import Foundation
class VerifyClient {
    public static func verifyClient(lastName: String, firstName: String, middleName: String, suffix: String, addr1: String, addr2: String, city: String, state: String, zip: String, phone: String, practice: SDPractice) -> ( errNo:Int, errDescr:String ){
        if lastName == "" {
            return (errNo:1, errDescr:"Client must have a last name")
        }
        if practice.internalId ?? -1 < 1 {
            return (errNo:2, errDescr:"Client must have a valid practice")

        }
        return (errNo:0, errDescr: "")
    }
}
