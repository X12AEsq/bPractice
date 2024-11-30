//
//  DocumentMenu.swift
//  bLawPractice
//
//  Created by Morris Albers on 11/27/24.
//

import SwiftUI

struct DocumentMenu: View {
    @Environment(\.modelContext) var modelContext
    @EnvironmentObject var CVModel:CommonViewModel
    @EnvironmentObject var nav: NavigationStateManager
    var practice: SDPractice
    
    var body: some View {
        
        VStack(alignment: .leading) {
            NavigationStack(path: $nav.selectionPath) {
                List {
                    NavigationLink(destination: Docket(practice: practice)) {
                        Text("Docket")
                            .font(.system(size: 30))
                    }
                    NavigationLink(destination: MonthlyReport(practice: practice)) {
                        Text("Monthly Report")
                            .font(.system(size: 30))
                    }
                }
                .navigationTitle(moduleTitle())
                Spacer()
            }
        }
    }
    
    func moduleTitle() -> String {
        let prName = practice.name ?? "Unidentified Practice"
        return prName + " Documents"
    }
}

//#Preview {
//    DocumentMenu()
//}
