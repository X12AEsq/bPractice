//
//  SelectCause.swift
//  bLawPractice
//
//  Created by Morris Albers on 11/19/24.
//

import SwiftUI
import SwiftData

struct SelectCause: View {
    struct listEntry: Identifiable {
        var id: String
        var cause:SDCause?
        
        init(id: String, cause: SDCause?) {
            self.id = id
            self.cause = cause
        }
    }

    @Environment(\.modelContext) var modelContext
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var CVModel:CommonViewModel
    @EnvironmentObject var nav: NavigationStateManager

    @Query(sort: [SortDescriptor(\SDCause.causeNo)]) var sortedCauses: [SDCause]
    
    @State var filterString:String = ""
    
    var practice: SDPractice
    var option: String

    var body: some View {
        VStack {
            TextField("Cause Number", text: $filterString)
                .font(.system(size: 20))
                .padding(.leading, 20)
                .padding(.bottom, 20)
            List(filteredList(filter: filterString), id: \.id ) { cauEN in
                NavigationLink(cauEN.id, value: NavEditCause(id: cauEN.cause?.causeDescr ?? "Add Cause", selectionArgument: cauEN.cause ?? SDCause()))
            }
            .navigationDestination(for: NavEditCause.self) { selValue in
                if selValue.id == "Add Cause" {
                    EditCause(practice: practice, option: "Add", cause: SDCause())
                } else {
                    if option == "Inq" {
                        DisplayCause(practice: practice)
                    } else {
                        EditCause(practice: practice, option: "Mod", cause: selValue.selectionArgument)
                    }
                }
            }
            .navigationTitle(moduleTitle())
            .navigationBarTitleDisplayMode(.inline)        }
        .onAppear() {
            print(option)
            print("")
        }
    }
    
    
    func filteredList(filter:String) -> [listEntry] {
        var returnList: [listEntry] = [listEntry(id: "Add Cause", cause: nil)]
//        let prefix = filter.lowercased()
        for cau in sortedCauses.filter( { $0.causeDescr.lowercased().hasPrefix(filterString.lowercased()) } ) {
            var descr: String = cau.causeDescr
            if let workClient: SDClient = cau.client {
                descr = descr + workClient.fullName
            }
            returnList.append(listEntry(id: descr, cause: cau))
        }
        return returnList
    }
            
    func moduleTitle() -> String {
        let prName = practice.name ?? "Unidentified Practice"
        return prName + " Causes"
    }

}

//#Preview {
//    SelectCause()
//}
