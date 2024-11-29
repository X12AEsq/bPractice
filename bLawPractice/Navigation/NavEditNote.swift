//
//  NavEditNote.swift
//  bLawPractice
//
//  Created by Morris Albers on 11/26/24.
//

import Foundation

struct NavEditNote: Hashable {
    var id: UUID
    var option: String
    var representation: SDRepresentation?
    var note: SDNote?
    
    init(id: UUID, option: String, representation: SDRepresentation?, note: SDNote?) {
        self.id = id
        self.option = option
        self.representation = representation
        self.note = note
    }
}
