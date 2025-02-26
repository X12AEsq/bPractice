//
//  RepresentationSorts.swift
//  bLawPractice
//
//  Created by Morris Albers on 2/24/25.
//

import Foundation
struct RepresentationSorts {
    public static var representationSorts:[String] = ["Assigned Date", "Closed Date", "Active", "Client Name"]
    public static func xlateType(inType:String) -> (valid:Bool, descr:String, Selector:Int) {
        switch inType {
        case "Assigned Date":
            return (true, "Assigned Date", 1)
        case "Closed Date":
            return (true, "Closed Date", 2)
        case "Active":
            return (true, "Active", 3)
        case "Client Name":
            return (true, "Client Name", 4)
        default:
            return (false, "Invalid", -1)
        }
    }
}
