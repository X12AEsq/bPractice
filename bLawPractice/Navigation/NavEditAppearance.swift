//
//  NavEditAppearance.swift
//  bLawPractice
//
//  Created by Morris Albers on 11/24/24.
//

import Foundation

struct NavEditAppearance: Hashable {
    var id: UUID
    var option: String
    var representation: SDRepresentation?
    var appearance: SDAppearance?
    
    init(id: UUID, option: String, representation: SDRepresentation?, appearance: SDAppearance?) {
        self.id = id
        self.option = option
        self.representation = representation
        self.appearance = appearance
    }
}
