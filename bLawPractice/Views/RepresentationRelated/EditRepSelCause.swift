//
//  EditRepSelCause.swift
//  bLawPractice
//
//  Created by Morris Albers on 11/28/24.
//
import Foundation
import SwiftUI
import SwiftData

extension EditRepresentation {
    struct causeListEntry: Identifiable {
        var id: String
        var cause:SDCause?
        
        init(id: String, cause: SDCause?) {
            self.id = id
            self.cause = cause
        }
    }
    
    struct selCause: View {
        @EnvironmentObject var CVModel:CommonViewModel

        @Query(sort: [SortDescriptor(\SDCause.causeNo)]) var sortedCauses: [SDCause]
        
        @Binding var gettingCause: Bool
        @Binding var causeSelected: SDCause
        @State var causeFilterString:String = ""
        
        var body: some View {
            VStack(alignment: .leading) {
                TextField("Cause Number", text: $causeFilterString)
                    .font(.system(size: 20))
                    .padding(.leading, 20)
                    .padding(.bottom, 20)
            }
            ScrollView {
                LazyVStack {
                    ForEach(causeFilteredList(filter: causeFilterString)) { cau in
                        HStack{
                            Button(cau.id) {
                                CVModel.selectedCause = cau.cause
                                causeSelected = cau.cause ?? SDCause()
                                gettingCause = false
                            }
                            .buttonStyle(CustomButton1())
                            Spacer()
                        }
                        .padding(.leading, 20)
                        .padding(.bottom, 5)
                    }
                }
            }
        }
        
        func causeFilteredList(filter:String) -> [causeListEntry] {
            var returnList: [causeListEntry] = []
            //        let prefix = filter.lowercased()
            for cau in sortedCauses.filter( { $0.causeDescr.lowercased().hasPrefix(causeFilterString.lowercased()) } ) {
                var descr: String = cau.causeDescr
                if let workClient: SDClient = cau.client {
                    descr = descr + workClient.fullName
                }
                returnList.append(causeListEntry(id: prettyDescription(inDescr: descr), cause: cau))
            }
            return returnList
        }
        
        func prettyDescription(inDescr: String) -> String {
            let trimmedDescr = inDescr.trimmingCharacters(in: .whitespacesAndNewlines)
            let descr = FormattingService.ljf(base: trimmedDescr, len: 50)
            return "  \(descr)"
        }
    }
}
