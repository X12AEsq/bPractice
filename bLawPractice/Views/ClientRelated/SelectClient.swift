//
//  SelectClient.swift
//  bLawPractice
//
//  Created by Morris Albers on 11/19/24.
//

import SwiftUI
import SwiftData

struct SelectClient: View {
    struct listEntry: Identifiable {
        var id: String
        var client:SDClient?
        
        init(id: String, client: SDClient?) {
            self.id = id
            self.client = client
        }
    }
    
    @Environment(\.modelContext) var modelContext
    @EnvironmentObject var CVModel:CommonViewModel
    @EnvironmentObject var nav: NavigationStateManager

    @Query(sort: [SortDescriptor(\SDClient.lastName),
                  SortDescriptor(\SDClient.firstName),
                  SortDescriptor(\SDClient.middleName)]) var alphaClients: [SDClient]
    
    @State var filterString:String = ""
    
//    var backButtonPlacement: ToolbarItemPlacement {
//        #if os(iOS)
//        ToolbarItemPlacement.navigationBarLeading
//        #else
//        ToolbarItemPlacement.navigation
//        #endif
//    }
    
    var practice: SDPractice
    var option: String

    var body: some View {
        VStack {
            TextField("Client Last, First, Middle", text: $filterString)
                .font(.system(size: 20))
                .padding(.leading, 20)
                .padding(.bottom, 20)
            List(filteredList(filter: filterString), id: \.id ) { cliEN in
                NavigationLink(cliEN.client?.fullName ?? "Add Client", value: NavEditClient(selectionArgument: cliEN.client ?? SDClient()))
            }
            .navigationDestination(for: NavEditClient.self) { selValue in
                if option == "Inq" {
                    DisplayClient(practice: practice, client: SDClient())
                } else {
                    if selValue.selectionArgument.lastName == "" {
                        EditClient(practice: practice, option: "Add", client: SDClient())
                    } else {
                        EditClient(practice: practice, option: "Mod", client: selValue.selectionArgument)
                    }
                }
            }
            .navigationTitle(moduleTitle())
            .navigationBarTitleDisplayMode(.inline)
            .onAppear() {
                print("")
            }
//            .navigationBarBackButtonHidden()
//            .toolbar {
//                ToolbarItem(placement: backButtonPlacement) {
//                    Button {
//                        nav.selectionPath.removeLast()
//                    } label: {
//                        Image(systemName: "chevron.left")
//                    }
//                }
//            }
        }
    }
    
    func filteredList(filter:String) -> [listEntry] {
        var returnList: [listEntry] = [listEntry(id: "", client: nil)]
        let prefix = filter.lowercased()
        for cli in alphaClients.filter( { $0.fullName.lowercased().hasPrefix(prefix) } ) {
            returnList.append(listEntry(id: cli.fullName, client: cli))
        }
        return returnList
    }
            
    func moduleTitle() -> String {
        let prName = practice.name ?? "Unidentified Practice"
        return prName + " Clients"
    }

}

//#Preview {
//    SelectClient()
//}
