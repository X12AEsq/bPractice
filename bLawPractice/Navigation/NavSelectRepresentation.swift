//
//  NavSelectRepresentation.swift
//  bLawPractice
//
//  Created by Morris Albers on 11/22/24.
//

struct NavSelectRepresentation: Hashable {
    var selectionArgument: String
    
    init(selectionArgument: String) {
        self.selectionArgument = selectionArgument
    }
}
