//
//  SelectRepresentation.swift
//  bLawPractice
//
//  Created by Morris Albers on 11/21/24.
//

import SwiftUI
import SwiftData

struct SelectRepresentation: View {
    struct listEntry: Identifiable {
        var id: UUID
        var name: String
        var cause: String
        var header: String
        var rep: SDRepresentation
        
        init(name: String, cause: String, header: String, rep: SDRepresentation) {
            self.id = UUID()
            self.name = name
            self.cause = cause
            self.header = header
            self.rep = rep
        }
        
        init() {
            self.id = UUID()
            self.name = ""
            self.cause = ""
            self.header = ""
            self.rep = SDRepresentation()
        }
    }
    
    @Environment(\.modelContext) var modelContext
    @EnvironmentObject var CVModel:CommonViewModel
    @EnvironmentObject var nav: NavigationStateManager

    @Query(sort: [SortDescriptor(\SDRepresentation.internalID)]) var sortedRepresentations: [SDRepresentation]
    
    @State var filterString:String = ""
    @State var sortOption:String = "N"
    @State var selectionList:[listEntry] = []
    
    var practice: SDPractice
    var option: String
    
    var body: some View {
        VStack {
            TextField("Client Last, First, Middle", text: $filterString)
                .font(.system(size: 20))
                .padding(.leading, 20)
                .padding(.bottom, 20)
             List(filteredList(option: sortOption, filter: filterString), id: \.id ) { repEN in
                NavigationLink(repEN.header, value: NavEditRepresentation(id: "", selectionOption: repEN.header, selectionArgument: repEN.rep))
            }
            .navigationDestination(for: NavEditRepresentation.self) { selValue in
//                if option == "Inq" {
//                    DisplayClient(practice: practice, client: SDClient())
//                } else {
                if selValue.selectionOption == "Add Representation" {
                        EditRepresentation(practice: practice, option: "Add")
                    } else {
                        EditRepresentation(practice: practice, option: "Mod", rep: selValue.selectionArgument)
                    }
//                }
            }
            .navigationDestination(for: NavEditAppearance.self) { selValue in
                EditAppearance(option: "Mod", practice: practice, representation: selValue.representation, appearance: selValue.appearance)
            }
            .navigationTitle(moduleTitle())
        }
        .onAppear {
            selectionList = buildList(option: sortOption)
        }
    }
    
    func buildList(option:String)  -> [listEntry] {
        var returnList: [listEntry] = []
        for rep in sortedRepresentations {
            var repListEntry = listEntry()
            if let name = rep.client?.fullName {
                repListEntry.name = name
            } else {
                repListEntry.name = "Unidentified Client"
            }
            if let cause = rep.cause?.causeNo {
                repListEntry.cause = cause
            } else {
                repListEntry.cause = "Unidentified Cause"
            }
            if option == "N" {
                repListEntry.header = (rep.client?.fullName ?? "") + " - " + (rep.cause?.causeNo ?? "")
            } else {
                repListEntry.header = (rep.cause?.causeNo ?? "") + " - " + (rep.client?.fullName ?? "")
            }
            repListEntry.header += " - \(rep.active ? "Active" : "Closed") \(rep.primaryCategory)"
            repListEntry.rep = rep
            returnList.append(repListEntry)
        }
        return returnList
    }
    
    func filteredList(option:String, filter:String) -> [listEntry] {
        var returnList: [listEntry] = [listEntry(name: "Add Representation", cause: "Add Representation", header: "Add Representation", rep: SDRepresentation())]
        let prefix = filter.lowercased()
        if option == "N" {
            returnList = returnList + selectionList.filter( { $0.name.lowercased().hasPrefix(prefix) } ).sorted(by: { $0.name < $1.name } )
            return returnList
        } else {
            returnList = returnList + selectionList.filter( { $0.cause.lowercased().hasPrefix(prefix) } ).sorted(by: { $0.cause < $1.cause } )
            return returnList
        }
    }
            
    func moduleTitle() -> String {
        let prName = practice.name ?? "Unidentified Practice"
        return prName + " Representations"
    }
}

//#Preview {
//    SelectRepresentation()
//}
