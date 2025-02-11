//
//  EditRepresentation.swift
//  bLawPractice
//
//  Created by Morris Albers on 11/22/24.
//

import SwiftUI
import SwiftData

struct EditRepresentation: View {
    struct listEntry: Identifiable {
        var id: String
        var cause:SDCause?
        
        init(id: String, cause: SDCause?) {
            self.id = id
            self.cause = cause
        }
    }
    
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var CVModel:CommonViewModel
    @EnvironmentObject var nav: NavigationStateManager
    
    @Query(sort: [SortDescriptor(\SDRepresentation.internalID, order: .reverse)]) var sortedRepresentations: [SDRepresentation]
    @Query(sort: [SortDescriptor(\SDCause.causeNo)]) var sortedCauses: [SDCause]
    
    @State var startInternalID:Int = -1
    @State var startActive: Bool = false
    @State var startAssignedDateTime: Date = Date.distantPast
    @State var startDispositionDateTime: Date = Date.distantPast
    @State var startDispositionType: String = "UNK"
    @State var startDispositionAction:String = "UNK"
    @State var startPrimaryCategory:String = "UNK"
    @State var startCause:SDCause? = nil
    @State var startClient:SDClient? = nil
    @State var startAppearances:[SDAppearance] = [SDAppearance]()
    @State var startNotes:[SDNote] = [SDNote]()
    
    @State var workInternalID:Int = -1
    @State var workActive: Bool = false
    @State var workAssignedDateTime: Date = Date.distantPast
    @State var workDispositionDateTime: Date = Date.distantPast
    @State var workDispositionType: String = "UNK"
    @State var workDispositionAction:String = "UNK"
    @State var workPrimaryCategory:String = "UNK"
    @State var workCause:SDCause = SDCause()
    @State var workClient:SDClient? = nil
    @State var workAppearances:[SDAppearance] = [SDAppearance]()
    @State var workNotes:[SDNote] = [SDNote]()
    
    @State var workCauseInternalID: Int = -1
    @State var workCauseCauseNo: String = ""
    @State var workCauseCauseType: String = ""
    @State var workCauseLevel: String = ""
    @State var workCauseCourt: String = ""
    @State var workCauseOriginalCharge: String = ""

    @State var deleteFlag:Bool = false
    
    @State var statusMessage:String = ""
    
    @State var filterString:String = ""
    @State var sortOption:String = "N"
    @State var selectionList:[listEntry] = []
    @State var gettingCause = false
    
    var practice: SDPractice
    var option: String
    var rep: SDRepresentation?
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                Text(moduleTitle())
                    .font(.system(size: 30))
                    .padding(.leading, 20)
                    .padding(.bottom, 20)
                if statusMessage != "" {
                    Text(statusMessage)
                        .font(.body)
                        .foregroundColor(Color.red)
                        .multilineTextAlignment(.leading)
                        .padding(.bottom)
                }
            }
            Form {
                Section(header: Text("Representation \(workInternalID)").background(Color.teal).foregroundColor(.white).font(.system(size: 20))) {
                    HStack {
                        if workActive {
                            Text("Representation is active")
                        } else {
                            Text("Representation is inactive")
                        }
                        Button(action: {
                            workActive.toggle()
                            if startActive != workActive {
                                if !workActive {
                                    workDispositionDateTime = Date()
                                }
                            }
                        })
                        {
                            if workActive {
                                Text("Make Inactive")
                            } else {
                                Text("Make Active")
                            }
                        }
                    }
                    HStack {
                        Text("Assigned:")
                        DatePicker("", selection: $workAssignedDateTime, displayedComponents: .date)
                    }
                    HStack {
                        Text("Representation Category")
                        Picker("", selection: $workPrimaryCategory) {
                            ForEach(RepresentationCategories.representationCategories, id: \.self) {
                                Text($0)
                            }
                        }
                        Text(RepresentationCategories.xlateCategory(inCat: workPrimaryCategory).descr)
                    }
                    if !workActive {
                        HStack {
                            Text("Disposed:")
                            DatePicker("", selection: $workDispositionDateTime, displayedComponents: .date)
                        }
                        HStack {
                            Text("Disposition Type")
                            Picker("", selection: $workDispositionType) {
                                ForEach(RepresentationDispositionTypes.dispositionTypes, id: \.self) {
                                    Text($0)
                                }
                            }
                            Text(RepresentationDispositionTypes.xlateType(inType: workDispositionType).descr)
                        }
                        HStack {
                            Text("Disposition Action")
                            Picker("", selection: $workDispositionAction) {
                                ForEach(RepresentationActions.representationActions, id: \.self) {
                                    Text($0)
                                }
                            }
                            Text(RepresentationActions.xlateAction(inAction: workDispositionAction).descr)
                        }
                    }
                }
                Section {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Cause: \(workCause.internalID) Number:\(workCause.causeNo ?? "No Cause") Type:\(workCause.causeType ?? "No Type") level:\(workCause.level ?? "No Level") court:\(workCause.court ?? "No Court") charge:\(workCause.originalCharge ?? "No Charge")")
                        }
                        HStack {
                            Text("Client: \(workCause.client?.internalID ?? -1) Name:\(workCause.client?.lastName ?? "No Name") \(workCause.client?.firstName ?? "") \(workCause.client?.middleName ?? "") Addr:\(workCause.client?.addr1 ?? "") \(workCause.client?.addr2 ?? "") \(workCause.client?.city ?? "") \(workCause.client?.state ?? "")\(workCause.client?.zip ?? "")")
                        }
                        if gettingCause {
                            selCause(gettingCause: $gettingCause, causeSelected: $workCause)
                        }
                    }
                }
                Section {
                    NavigationLink(destination: EditAppearance(option: "Add", practice: practice, representation: rep, appearance: nil)) {
                        Text("Add Appearance")
                    }
                    List(workAppearances, id: \.id ) { aprEN in
                        NavigationLink(aprEN.printLine, value: NavEditAppearance(id: UUID(), option: "Mod", representation: rep, appearance: aprEN))
                    }
                }
                Section {
                    NavigationLink(destination: EditNote(option: "Add", practice: practice, representation: rep, note: nil)) {
                        Text("Add Note")
                    }
                    List(workNotes, id: \.id ) { noteEN in
//                        Text(noteEN.printLine)
                        NavigationLink(noteEN.printLine, value: NavEditNote(id: UUID(), option: "Mod", representation: rep, note: noteEN))
                    }
                }
            }
            .onAppear {
                workInternalID = CVModel.selectedCause?.internalID ?? -1
                workCause = CVModel.selectedCause ?? SDCause()
                resetCause(cause: workCause)
                workAppearances = rep?.appearances?.sorted(by: { $0.appearDateTime < $1.appearDateTime } ) ?? []
            }
            .onFirstAppear {
                initWorkArea()
            }
            .toolbar {
                Button {
                    gettingCause = true
                } label: {
                    Label("Change Cause", systemImage: "rectangle.2.swap").labelStyle(.titleAndIcon)
                }
//                .foregroundColor(.white)
//                .background(Color.green)
                if option != "Add" {
                    if deleteFlag {
                        Button {
                            print("delete this")
                            deleteFlag = false
                            modelContext.delete(rep!)
                            do {
                                try modelContext.save()
                                CVModel.selectedRepresentation = nil
                                statusMessage = ""
                                initWorkArea()
                                if nav.selectionPath.count > 0 {
                                    nav.selectionPath.removeLast()
                                }
                            } catch {
                                statusMessage = "Error deleting representation: \(error.localizedDescription)"
                            }
                        } label: {
                            Label("Really?", systemImage: "trash").labelStyle(.titleAndIcon)
                        }
                        .foregroundColor(.black)
                        .background(Color.red)
                        Button {
                            print("delete this")
                            deleteFlag = false
                        } label: {
                            Label("Do not delete", systemImage: "trash.slash").labelStyle(.titleAndIcon)
                        }
                        .foregroundColor(.white)
                        .background(Color.green)
                    } else {
                        Button {
                            deleteFlag = true
                        } label: {
                            Label("Delete", systemImage: "trash").labelStyle(.titleAndIcon)
                        }
                        .foregroundColor(.black)
                        .background(Color.red)
                    }
                }
                
                if representationModified() {
                    Button {
                        var workingInternalID = workInternalID
                        if option == "Add" {
                            if sortedRepresentations.count > 0 {
                                workingInternalID = sortedRepresentations[0].internalID
                                workingInternalID += 1
                            } else {
                                workingInternalID = 1
                            }
                        }
                        workInternalID = workingInternalID 
                        let verResult = VerifyRepresentation.verifyRepresentation(internalID: workInternalID, active: workActive, assignedDate: workAssignedDateTime, dispositionDate: workDispositionDateTime, dispositionType: workDispositionType, dispositionAction: workDispositionAction, primaryCategory: workPrimaryCategory, cause: workCause, appearances: workAppearances, notes: workNotes, practice: practice)
                        if verResult.errNo == 0 {
                            statusMessage = ""
                            if option == "Add" {
                                if workingInternalID > 0 {
                                    CVModel.selectedRepresentation = SDRepresentation(internalID: workInternalID, active: workActive, assignedDate: workAssignedDateTime, dispositionDate: workDispositionDateTime, dispositionType: workDispositionType, dispositionAction: workDispositionAction, primaryCategory: workPrimaryCategory)
                                    CVModel.selectedRepresentation?.cause = workCause
                                    if workClient != nil {
                                        CVModel.selectedRepresentation?.client = workClient
                                    } else {
                                        if let tempClient = CVModel.selectedRepresentation?.cause?.client {
                                            CVModel.selectedRepresentation?.client = tempClient
                                        }
                                    }
                                    modelContext.insert(CVModel.selectedRepresentation!)
                                    do {
                                        try modelContext.save()
                                        statusMessage = ""
                                        initWorkArea()
                                    } catch {
                                        statusMessage = "Error inserting new representation: \(error.localizedDescription)"
                                    }
                                    if nav.selectionPath.count > 0 {
                                        nav.selectionPath.removeLast()
                                    }
                                } else {
                                    statusMessage = "Error assigning new representation number"
                                }
                            } else {    // end of option-Add
                                CVModel.selectedRepresentation?.internalID = workInternalID
                                CVModel.selectedRepresentation?.active = workActive
                                CVModel.selectedRepresentation?.assignedDateTime = workAssignedDateTime
                                CVModel.selectedRepresentation?.dispositionDateTime = workDispositionDateTime
                                CVModel.selectedRepresentation?.dispositionType = workDispositionType
                                CVModel.selectedRepresentation?.dispositionAction = workDispositionAction
                                CVModel.selectedRepresentation?.primaryCategory = workPrimaryCategory
                                CVModel.selectedRepresentation?.cause = workCause
                                CVModel.selectedRepresentation?.client = workClient
                                CVModel.selectedRepresentation?.appearances = workAppearances
                                CVModel.selectedRepresentation?.practice = practice
                                do {
                                    try modelContext.save()
                                    statusMessage = ""
                                    initWorkArea()
                                } catch {
                                    statusMessage = "Error updating client: \(error.localizedDescription)"
                                }
                            }
                        } else {
                            statusMessage = verResult.errDescr
                        }
                    } label: {
                        Label("Save", systemImage: "folder.badge.plus").labelStyle(.titleAndIcon)
                    }
                }
            }
        }
    }
    
    func resetCause(cause:SDCause?) {
        workCauseInternalID = cause?.internalID ?? -1
        workCauseCauseNo = cause?.causeNo ?? ""
        workCauseCauseType = cause?.causeType ?? ""
        workCauseLevel = cause?.level ?? ""
        workCauseCourt = cause?.court ?? ""
        workCauseOriginalCharge = cause?.originalCharge ?? ""
    }
    
    func initWorkArea() {
        if option == "Add" {
            startInternalID = -1
            startActive = true
            startAssignedDateTime = Date()
            startDispositionDateTime = Date.distantFuture
            startDispositionType = "UNK"
            startDispositionAction = "UNK"
            startPrimaryCategory = "UNK"
            startCause = nil
            startClient = nil
            startAppearances = []
        } else {
            if let representation: SDRepresentation = rep {
                CVModel.selectedRepresentation = representation
                startInternalID = representation.internalID
                startActive = representation.active
                startAssignedDateTime = representation.assignedDateTime
                startDispositionDateTime =  representation.dispositionDateTime
                startDispositionType = representation.dispositionType
                startDispositionAction = representation.dispositionAction
                startPrimaryCategory = representation.primaryCategory
                startCause = representation.cause
                if let tempClient = representation.client {
                    startClient = tempClient
                } else if let tempClient = representation.cause?.client {
                    startClient = tempClient
                } else {
                    startClient = nil
                }
                startAppearances = representation.appearances?.sorted(by: { $0.appearDateTime < $1.appearDateTime } ) ?? []
                startNotes = representation.notes?.sorted(by: { $0.noteDateTime < $1.noteDateTime } ) ?? []
            }
            workInternalID = startInternalID
            workActive = startActive
            workAssignedDateTime = startAssignedDateTime
            workDispositionDateTime = startDispositionDateTime
            workDispositionType = startDispositionType
            workDispositionAction = startDispositionAction
            workPrimaryCategory = startPrimaryCategory
            workCause = startCause ?? SDCause()
            workClient = startClient
            workAppearances = startAppearances
            workNotes = startNotes
            
            resetCause(cause: workCause)
        }
    }
    
    func representationModified() -> Bool {
        if startInternalID != workInternalID { return true }
        if startActive != workActive { return true }
        if startAssignedDateTime != workAssignedDateTime { return true }
        if startDispositionDateTime !=  workDispositionDateTime { return true }
        if startDispositionType != workDispositionType { return true }
        if startDispositionAction != workDispositionAction { return true }
        if startPrimaryCategory != workPrimaryCategory { return true }
        if startCause != workCause { return true }
        if startClient != workClient { return true }
        if workAppearances.count != startAppearances.count { return true }
        return false
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
        return "\(prName) \(option) Representation"
    }
}

//#Preview {
//    EditRepresentation()
//}
