//
//  NavAddAppearance.swift
//  bLawPractice
//
//  Created by Morris Albers on 11/24/24.
//

import Foundation

struct NavAddAppearance: Hashable {
    var id: UUID
    var option: String
    var representation: SDRepresentation?
    
    init(id: UUID, option: String, representation: SDRepresentation?) {
        self.id = id
        self.option = option
        self.representation = representation
    }
}
