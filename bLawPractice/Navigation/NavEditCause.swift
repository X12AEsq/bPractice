//
//  NavEditCause.swift
//  bLawPractice
//
//  Created by Morris Albers on 11/20/24.
//

struct NavEditCause: Hashable {
    var id: String
    var selectionArgument: SDCause
    
    init(id: String, selectionArgument: SDCause) {
        self.id = id
        self.selectionArgument = selectionArgument
    }
}
