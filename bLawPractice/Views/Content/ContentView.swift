//
//  ContentView.swift
//  bLawPractice
//
//  Created by Morris Albers on 11/17/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @EnvironmentObject var CVModel:CommonViewModel
    @Environment(\.modelContext) var modelContext
    
    @Query var practices: [SDPractice]
    @Query(filter: #Predicate<SDPractice> { prac in
        !(prac.testing ?? true) }) var prodPractice: [SDPractice]
    
    @Query var clients: [SDClient]
    @Query(sort: [SortDescriptor(\SDClient.internalID)]) var sortedClients: [SDClient]
    
    @Query var causes: [SDCause]
    @Query(sort: [SortDescriptor(\SDCause.internalID)]) var sortedCauses: [SDCause]
    
    @Query var representations: [SDRepresentation]
    @Query(sort: [SortDescriptor(\SDRepresentation.internalID)]) var sortedRepresentations: [SDRepresentation]
    
    @Query var appearances: [SDAppearance]
    @Query(sort: [SortDescriptor(\SDAppearance.internalID)]) var sortedAppearances: [SDAppearance]
    
    @Query var notes: [SDNote]
    @Query(sort: [SortDescriptor(\SDNote.internalID)]) var sortedNotes: [SDNote]
    
    @StateObject var nav = NavigationStateManager()
    
    @State var selected: SDPractice?
    
    @State var backupURL: URL?
    @State var backupReady:Bool = false

    var body: some View {
        VStack {
        HStack {
            Text("\(clients.count) Clients")
            Text(" \(causes.count) Causes")
            Text(" \(representations.count) Representations")
            Text(" \(appearances.count) Appearances")
            Text(" \(notes.count) Notes")
        }
            NavigationStack(path: $nav.selectionPath) {
                List {
                    NavigationLink("Select Client", value: NavSelectClient(selectionArgument: "main"))
                        .font(.system(size: 30))
                    NavigationLink("Select Cause", value: NavSelectCause())
                        .font(.system(size: 30))
                    NavigationLink("Select Representation", value: NavSelectRepresentation(selectionArgument: ""))
                        .font(.system(size: 30))
                    NavigationLink(destination: DocumentMenu(practice: selected ?? SDPractice())) {
                        Text("Documents")
                        .font(.system(size: 30))
                    }
                }
                
                .navigationDestination(for: NavSelectClient.self) { selValue in
                    SelectClient(practice: selected ?? SDPractice(), option: "Mod")
                }
                .navigationDestination(for: NavSelectCause.self) { selValue in
                    SelectCause( practice: selected ?? SDPractice(), option: "Mod")
                }
                .navigationDestination(for: NavSelectRepresentation.self) { selValue in
                    SelectRepresentation(practice: selected ?? SDPractice(), option: "Mod")
                }
                .navigationTitle(practiceName())
                Spacer()
                    .toolbar {
                        Button {
                            cleanup()
                        } label: {
                            Label("Cleanup", systemImage: "trash").labelStyle(.titleAndIcon)
                        }
                        Button {
                            restoreData()
                        } label: {
                            Label("Restore", systemImage: "icloud.and.arrow.up").labelStyle(.titleAndIcon)
                        }
                        if backupReady{
                            ShareLink(item: backupURL!)
                            Button {
                                backupReady = false
                            } label: {
                                Label("Clear Backup", systemImage: "square.and.arrow.up.trianglebadge.exclamationmark").labelStyle(.titleAndIcon)
                            }
                        } else {
                            Button {
                                backupURL = createFlatBackup()
                                backupReady = true
                            } label: {
                                Label("Backup", systemImage: "icloud.and.arrow.down").labelStyle(.titleAndIcon)
                            }
                        }
                    }
                Spacer()
            }
        }
        .onAppear(perform: {
            if prodPractice.count > 0 {
                selected = prodPractice[0]
            } else {
                selected = nil as SDPractice?
            }
//            if practices.count == 0 {
//                let practicet = SDPractice(addr1: "151 N. Washington St.", addr2: "PO Box 999", city: "Armpit", internalID: 1, name: "Test Practice", shortName: "Test Law Practice", state: "KY", testing: true, zip: "90909")
//                modelContext.insert(practicet)
//                do {
//                    try modelContext.save()
//                } catch {
//                    print("error: \(error.localizedDescription)")
//                }
//                let practice = SDPractice(addr1: "159 W. Crockett St.", addr2: "PO Box 653", city: "La Grange", internalID: 2, name: "Morris E. Albers II, Attorney and Counsellor at Law, PLLC", shortName: "Albers Law Practice", state: "TX", testing: false, zip: "78945")
//                modelContext.insert(practice)
//                do {
//                    try modelContext.save()
//                } catch {
//                    print("error: \(error.localizedDescription)")
//                }
//            }
//            let prodPractices = prodPractice
//            if prodPractices.count == 0 {
//                selected = SDPractice(addr1: "159 W. Crockett St.", addr2: "PO Box 653", city: "La Grange", internalID: 2, name: "Dummy Practice", shortName: "Dummy Practice", state: "TX", testing: false, zip: "78945")
//            } else {
//                selected = prodPractices[0]
//            }
        })
        .environmentObject(nav)
    }

    func practiceName() -> String {
        if prodPractice.count > 0 {
            return prodPractice[0].name ?? "No Practice Name"
        } else {
            return "Practice Query Empty"
        }
    }
    
    func cleanup() {
        
    }
    
    func createPackage() {
        
    }
}

//#Preview {
//    ContentView()
//        .modelContainer(for: Item.self, inMemory: true)
//}
