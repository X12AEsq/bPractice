//
//  NavEditRepresentation.swift
//  bLawPractice
//
//  Created by Morris Albers on 11/22/24.
//

struct NavEditRepresentation: Hashable {
    var id: String
    var selectionOption: String
    var selectionArgument: SDRepresentation
    
    init(id: String, selectionOption: String, selectionArgument: SDRepresentation) {
        self.id = id
        self.selectionOption = selectionOption
        self.selectionArgument = selectionArgument
    }
}
