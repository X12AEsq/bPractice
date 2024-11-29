//
//  DisplayCause.swift
//  bLawPractice
//
//  Created by Morris Albers on 11/28/24.
//

import SwiftUI

struct DisplayCause: View {
    @Environment(\.modelContext) var modelContext
    @EnvironmentObject var CVModel:CommonViewModel
    
    var practice: SDPractice
    var cause: SDCause?
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            .onAppear() {
                print("")
            }
    }
}

