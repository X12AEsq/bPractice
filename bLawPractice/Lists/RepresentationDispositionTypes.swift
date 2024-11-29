//
//  RepresentationDispositionTypes.swift
//  bLawPractice
//
//  Created by Morris Albers on 11/22/24.
//

import Foundation
struct RepresentationDispositionTypes {
    public static var dispositionTypes:[String] = ["PB", "JT", "OP", "BT", "MTRP", "MTAG", "OTH", "NS", "UNK"]
    public static func xlateType(inType:String) -> (valid:Bool, descr:String) {
        switch inType {
        case "PB":
            return (true, "Plea Bargain")
        case "JT":
            return (true, "Jury Trial")
        case "OP":
            return (true, "Open Plea")
        case "BT":
            return (true, "Bench Trial")
        case "MTRP":
            return (true, "Motion to Revoke")
        case "MTAG":
            return (true, "Motion to Adjudicate")
        case "OTH":
            return (true, "Other")
        case "NS":
            return (true, "Non Suit")
        case "UNK":
            return (true, "Not Specified")
        default:
            return (false, "Invalid")
        }
    }
}
