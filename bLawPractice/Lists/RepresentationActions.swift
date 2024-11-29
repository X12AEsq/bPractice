//
//  RepresentationActions.swift
//  bLawPractice
//
//  Created by Morris Albers on 11/22/24.
//

import Foundation
struct RepresentationActions {
    public static var representationActions:[String] = ["C", "A", "D", "DEF", "ADJ", "PTD", "OTH", "PROB", "AGRD", "UNK"]
    public static func xlateAction(inAction:String) -> (valid:Bool, descr:String) {
        switch inAction {
        case "C":
            return (true, "Conviction")
        case "A":
            return (true, "Acquittal")
        case "D":
            return (true, "Dismissal")
        case "DEF":
            return (true, "Deferred")
        case "ADJ":
            return (true, "Adjudicated")
        case "PTD":
            return (true, "PreTrial Diversion")
        case "OTH":
            return (true, "Other")
        case "PROB":
            return (true, "Probation")
        case "AGRD":
            return (true, "Agreement")
        case "UNK":
            return (true, "Not Specified")
        default:
            return (false, "Invalid")
        }
    }
}
