//
//  RepresentationCategories.swift
//  bLawPractice
//
//  Created by Morris Albers on 11/22/24.
//

import Foundation
struct RepresentationCategories {
    public static var representationCategories:[String] = ["ORIG", "MTR", "MTA", "CPS", "CIV", "UNK"]
    public static func xlateCategory(inCat:String) -> (valid:Bool, descr:String) {
        switch inCat {
        case "ORIG":
            return (true, "Original Criminal")
        case "MTR":
            return (true, "Motion to Revoke")
        case "MTA":
            return (true, "Motion to Adjudicate")
        case "CPS":
            return (true, "Child Protection")
        case "CIV":
            return (true, "Other Civil")
        case "UNK":
            return (true, "Not Specified")
        default:
            return (false, "Invalid")
        }
    }
}
