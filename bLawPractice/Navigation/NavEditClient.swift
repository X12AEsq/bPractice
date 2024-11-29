//
//  NavEditClient.swift
//  bLawPractice
//
//  Created by Morris Albers on 11/19/24.
//


struct NavEditClient: Hashable {
    var selectionArgument: SDClient
    
    init(selectionArgument: SDClient) {
        self.selectionArgument = selectionArgument
    }
}
