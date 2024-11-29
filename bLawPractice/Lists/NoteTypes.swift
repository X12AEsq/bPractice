//
//  NoteTypes.swift
//  bLawPractice
//
//  Created by Morris Albers on 11/26/24.
//

import Foundation
struct NoteTypes {
    public static var noteTypes:[String] = ["ORIG", "NOTE", "TODO", "JAIL", "UNK"]
    public static func xlateType(inType:String) -> (valid:Bool, descr:String) {
        switch inType {
        case "ORIG":
            return (true, "From conversion")
        case "JAIL":
            return (true, "Jail Visit")
        case "NOTE":
            return (true, "Note")
        case "TODO":
            return (true, "To Do")
        case "UNK":
            return (true, "Not Specified")
        default:
            return (false, "Invalid")
        }
    }

}
