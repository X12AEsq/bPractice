//
//  NavSelectClient.swift
//  bLawPractice
//
//  Created by Morris Albers on 11/19/24.
//

struct NavSelectClient: Hashable {
    var selectionArgument: String
    
    init(selectionArgument: String) {
        self.selectionArgument = selectionArgument
    }
}
