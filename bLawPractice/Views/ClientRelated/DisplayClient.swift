//
//  DisplayClient.swift
//  bLawPractice
//
//  Created by Morris Albers on 11/20/24.
//

import SwiftUI

struct DisplayClient: View {
    @Environment(\.modelContext) var modelContext
    @EnvironmentObject var CVModel:CommonViewModel
    
    var practice: SDPractice
    var client: SDClient?

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                Text(moduleTitle())
                    .font(.system(size: 30))
                    .padding(.leading, 20)
                    .padding(.bottom, 20)
            }
            VStack(alignment: .leading) {
                HStack {
                    Text("Last Name: ").foregroundColor(.mint)
                    Text(client?.lastName ?? "")
                }
                HStack {
                    Text("First Name: ").foregroundColor(.mint)
                    Text(client?.firstName ?? "")
                }
                HStack {
                    Text("Middle Name: ").foregroundColor(.mint)
                    Text(client?.middleName ?? "")
                }
                HStack {
                    Text("Suffix: ").foregroundColor(.mint)
                    Text(client?.suffix ?? "")
                }
            }
            VStack(alignment: .leading) {
                HStack {
                    Text("Address 1: ").foregroundColor(.mint)
                    Text(client?.addr1 ?? "")
                }
                HStack {
                    Text("Address 2: ").foregroundColor(.mint)
                    Text(client?.addr2 ?? "")
                }
                HStack {
                    Text("City: ").foregroundColor(.mint)
                    Text(client?.city ?? "")
                }
                 HStack {
                     Text("State: ").foregroundColor(.mint)
                     Text(client?.state ?? "")
                 }
                HStack {
                    Text("Zip: ").foregroundColor(.mint)
                    Text(client?.zip ?? "")
                }
            }
            VStack(alignment: .leading) {
                HStack {
                    Text("Telephone: ").foregroundColor(.mint)
                    Text(client?.phone ?? "")
                }
            }
            VStack(alignment: .leading) {
                HStack {
                    Text("Miscellaneous Docket Date \(String(describing: client?.miscDocketDate))")
                }
            }
        }
    }
    
    func moduleTitle() -> String {
        let prName = practice.name ?? "Unidentified Practice"
        return "\(prName) Display Client"
    }
}

//#Preview {
//    DisplayClient()
//}
