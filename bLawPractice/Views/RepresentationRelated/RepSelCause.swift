//
//  RepSelCause.swift
//  bLawPractice
//
//  Created by Morris Albers on 11/28/24.
//

import SwiftUI
import SwiftData

struct RepSelCause: View {
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
    
    var practice:SDPractice
        
    var body: some View {
        VStack(alignment: .leading) {
            TextField("Cause Number", text: $filterString)
                .font(.system(size: 20))
                .padding(.leading, 20)
                .padding(.bottom, 20)
            ScrollView {
                LazyVStack {
                    ForEach(filteredList(filter: filterString)) { cau in
                        HStack{
                            Button(cau.id) {
                                print("Button tapped!")
                                if nav.selectionPath.count > 0 {
                                    nav.selectionPath.removeLast()
                                }
                            }
                            .buttonStyle(CustomButton1())
                            Spacer()
                        }
                        .padding(.leading, 20)
                        .padding(.bottom, 5)
                   }
                }
            }
//            List(filteredList(filter: filterString), id: \.id ) { cauEN in
//                NavigationLink(cauEN.id, value: NavEditCause(id: cauEN.cause?.causeDescr ?? "Add Cause", selectionArgument: cauEN.cause ?? SDCause()))
//                causeSelected(cause: cauEN.cause)
//            }
            .navigationTitle(moduleTitle())
        }
        .onAppear() {
            print("")
        }
    }
    func filteredList(filter:String) -> [listEntry] {
        var returnList: [listEntry] = []
//        let prefix = filter.lowercased()
        for cau in sortedCauses.filter( { $0.causeDescr.lowercased().hasPrefix(filterString.lowercased()) } ) {
            var descr: String = cau.causeDescr
            if let workClient: SDClient = cau.client {
                descr = descr + workClient.fullName
            }
            returnList.append(listEntry(id: prettyDescription(inDescr: descr), cause: cau))
        }
        return returnList
    }
    
    func prettyDescription(inDescr: String) -> String {
        let trimmedDescr = inDescr.trimmingCharacters(in: .whitespacesAndNewlines)
        let descr = FormattingService.ljf(base: trimmedDescr, len: 50)
        return "  \(descr)"
    }
    func moduleTitle() -> String {
        let prName = practice.name ?? "Unidentified Practice"
        return prName + " Causes"
    }
    func causeSelected(cause:SDCause?) {
        print("")
    }
}

//#Preview {
//    RepSelCause()
//}
