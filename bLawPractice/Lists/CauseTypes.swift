//
//  CauseTypes.swift
//  bLawPractice
//
//  Created by Morris Albers on 11/20/24.
//

import Foundation
struct CauseTypeOptions {
    public static var causeTypeOptions = ["Appt", "Priv", "Fam", "UNK"]
    public static var defaultCauseTypeOption:String = "UNK"
    public static func xlateType(inType:String) -> (valid:Bool, descr:String) {
        switch inType {
        case "Appt":
            return (true, "Appointed")
        case "Priv":
            return (true, "Retained")
        case "Fam":
            return (true, "Family")
        case "UNK":
            return (true, "Not Specified")
        default:
            return (false, "Invalid")
        }
    }
}
