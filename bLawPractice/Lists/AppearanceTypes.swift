//
//  AppearanceTypes.swift
//  bLawPractice
//
//  Created by Morris Albers on 11/24/24.
//

import Foundation
struct AppearanceTypes {
    public static var appearanceTypes:[String] = ["INIT", "UNSC", "ORIG", "NISS", "JURY", "BENCH", "PLEA", "MOTN", "SENTC", "SHOWC", "FTA", "UNK"]
    public static func xlateType(inType:String) -> (valid:Bool, descr:String) {
        switch inType {
        case "ORIG":
            return (true, "From conversion")
        case "NISS":
            return (true, "Non Issue")
        case "JURY":
            return (true, "Jury Trial")
        case "BENCH":
            return (true, "Bench Trial")
        case "PLEA":
            return (true, "Enter Plea")
        case "MOTN":
            return (true, "Motions")
        case "SENTC":
            return (true, "Sentencing")
        case "SHOWC":
            return (true, "Show Cause")
        case "FTA":
            return (true, "FTA Hearing")
        case "UNK":
            return (true, "Not Specified")
        case "INIT":
            return (true, "Initial")
        case "UNSC":
            return (true, "Unscheduled")
        default:
            return (false, "Invalid")
        }
    }
}
