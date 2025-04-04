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
    @Query(sort: [SortDescriptor(\SDAppearance.internalID, order: .reverse)]) var sortedAppearances: [SDAppearance]
    
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
    
    @State var workAppearanceInternalID: Int = -1
    @State var workAppearDateTime: Date = Date.distantPast
    @State var workAppearDate: String = ""
    @State var workAppearTime: String = "0900"
    @State var workAppearNote: String = ""
    @State var workAppearReason: String = "UNK"
    
    @State var startAppearDateTime: Date = Date.distantPast
    @State var startAppearDate: String = ""
    @State var startAppearTime: String = "0900"
    @State var startAppearNote: String = ""
    @State var startAppearReason: String = "UNK"

    @State var deleteFlag:Bool = false
    @State var addAppearanceFlag:Bool = false
    @State var delAppearanceFlag:Bool = false
    @State var deletingAppearances:[Int] = []
    @State var deletingAppearance:Int = -1
    
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
                    .font(.system(size: 20).weight(.bold))
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
                                Text(" Make Inactive ")
                            } else {
                                Text(" Make Active ")
                            }
                        }
                        .buttonStyle(CustomButtonBlack())
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
                                .font(.system(size: 20).weight(.bold))
                        }
                        HStack {
                            Text("Client: \(workCause.client?.internalID ?? -1) Name:\(workCause.client?.lastName ?? "No Name") \(workCause.client?.firstName ?? "") \(workCause.client?.middleName ?? "") Addr:\(workCause.client?.addr1 ?? "") \(workCause.client?.addr2 ?? "") \(workCause.client?.city ?? "") \(workCause.client?.state ?? "")\(workCause.client?.zip ?? "")")
                                .font(.system(size: 20).weight(.bold))
                        }
                        if gettingCause {
                            selCause(gettingCause: $gettingCause, causeSelected: $workCause)
                        }
                    }
                }
                Section {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Appearances:").font(.system(size: 20).weight(.bold))
                            if option != "Add" {
                                Spacer()
/*
                                if appearanceEntered() {
                                    Button {
                                        workAppearanceInternalID = sortedAppearances[0].internalID + 1
                                        let verResult = VerifyAppearance.verifyAppearance(internalID: workAppearanceInternalID, appearDateTime: workAppearDateTime, appearNote: workAppearNote, appearReason: workAppearReason, representation: nil)
                                        if verResult.errNo == 0 {
                                            modelContext.insert(SDAppearance(internalID: workAppearanceInternalID, appearDateTime: workAppearDateTime, appearNote: workAppearNote, appearReason: workAppearReason, representation: rep))
                                            do {
                                                try modelContext.save()
                                                addAppearanceFlag = false
                                                initAppearance()
                                                workAppearances = rep?.appearances?.sorted(by: { $0.appearDateTime < $1.appearDateTime } ) ?? []
                                            } catch {
                                                statusMessage = "Error inserting new appearance: \(error.localizedDescription)"
                                            }
                                            
                                        } else {
                                            statusMessage = "Error: \(verResult.errDescr)"
                                        }
                                    } label: {
                                        Label("Save Appearance", systemImage: "folder.badge.plus").labelStyle(.titleAndIcon)
                                    }
                                }
*/
                                if !delAppearanceFlag {
                                    if !addAppearanceFlag {
                                        Button {
                                            addAppearanceFlag = true
                                            initAppearance()
                                        } label: {
                                            Label("Add Appearance ", systemImage: "calendar.badge.plus").labelStyle(.titleAndIcon)
                                        }
                                        .buttonStyle(CustomButtonGreen())
                                        Spacer()
                                    } else {
//                                        Button {
//                                            addAppearanceFlag = false
//                                            initAppearance()
//                                        } label: {
//                                            Label("Cancel Add ", systemImage: "calendar.badge.minus").labelStyle(.titleAndIcon)
//                                        }
//                                        Spacer()
                                    }
                                    if workAppearances.count > 0 {
                                        Button {
                                            delAppearanceFlag = true
//                                            addAppearanceFlag = false
                                            deletingAppearance = -1
                                            for apprEN in workAppearances {
                                                deletingAppearances.append(apprEN.internalID)
                                            }
                                        } label: {
                                            Label("Delete Appearance ", systemImage: "minus.diamond.fill").labelStyle(.titleAndIcon)
                                        }
                                        .buttonStyle(CustomButtonRed())
                                    }
                                } else {
                                    VStack {
                                        if deletingAppearance < 0 {
                                            List(workAppearances, id: \.id ) { aprEN in
                                                HStack {
                                                    Text(aprEN.printLine)
                                                        .padding(.top, 10)
                                                        .onTapGesture {
                                                            deletingAppearance = aprEN.internalID
                                                            print("\(aprEN.internalID)")
                                                        }
                                                    Spacer()
                                                }
                                            }
                                        } else {
                                            HStack {
                                                Button {
                                                    let retrieve = returnAppearance(reqID: deletingAppearance)
                                                    if retrieve.status {
                                                        modelContext.delete(retrieve.appr!)
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
                                                    } else {
                                                        statusMessage = "Error locating appearance  \(deletingAppearance)"
                                                    }
                                                } label: {
                                                    Label("Confirm Delete Appearance \(deletingAppearance)", systemImage: "trash").labelStyle(.titleAndIcon)
                                                }
                                                .buttonStyle(CustomButtonRed())
                                                Spacer()
                                                Button {
                                                    print("Do Not Delete Appearance \(deletingAppearance)")
                                                } label: {
                                                    Label("Do Not Delete Appearance \(deletingAppearance)", systemImage: "trash.slash").labelStyle(.titleAndIcon)
                                                }
                                                .buttonStyle(CustomButtonGreen())
                                            }
                                        }
                                    }
                                }
                            }
                        }
//                        HStack { Text("debug: \(delAppearanceFlag) \(addAppearanceFlag)") }
                        if !delAppearanceFlag {
                            List(workAppearances, id: \.id ) { aprEN in
//                                Text(aprEN.printLine)
                                apprLine(appr: aprEN)
                            }
                        }
                        Text(" ")
                        if addAppearanceFlag {
                            enterAppearance
/*
 
                            VStack(alignment: .leading) {
                                HStack {
                                    Text("Appearance Date:")
                                    DatePicker("", selection: $workAppearDateTime, displayedComponents: [.date]).onChange(of: workAppearDateTime, initial: true, {
                                            workAppearDate = DateService.dateDate2String(inDate:    workAppearDateTime, short:true)
                                        })
                                    HStack {
                                        Picker("Appearance Time:",
                                               selection: $workAppearTime) {
                                            Text("0900")
                                                .tag("0900")
                                            Text("1315")
                                                .tag("1315")
                                        }.onChange(of: workAppearTime, initial: true, { workAppearDateTime = DateService.shortDateTime2String(inDate: workAppearDate, inTime: workAppearTime) } )
                                    }
                                }//.padding(.trailing, proxy.size.width * 0.3)
                                HStack {
                                    Text("Note:")
                                    TextField("", text: $workAppearNote)
                                }
                                HStack {
                                    Text("Reason")
                                    Picker("", selection: $workAppearReason) {
                                        ForEach(AppearanceTypes.appearanceTypes, id: \.self) {
                                            Text($0)
                                        }
                                    }
                                    Text(AppearanceTypes.xlateType(inType: workAppearReason).descr)
                                }.padding(.trailing)
                            }
 
 */
                        }
                        //                    NavigationLink(destination: EditAppearance(option: "Add", practice: practice, representation: rep, appearance: nil)) {
                        //                        Text("Add Appearance")
                        //                    }
                        //                    List(workAppearances, id: \.id ) { aprEN in
                        //                        NavigationLink(aprEN.printLine, value: NavEditAppearance(id: UUID(), option: "Mod", representation: rep, appearance: aprEN))
                        //                    }
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
                .buttonStyle(CustomButtonGreen())
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
                        .buttonStyle(CustomButtonRed())
                        Button {
                            print("delete this")
                            deleteFlag = false
                        } label: {
                            Label("Do not delete", systemImage: "trash.slash").labelStyle(.titleAndIcon)
                        }
                        .buttonStyle(CustomButtonGreen())
                    } else {
                        Button {
                            deleteFlag = true
                        } label: {
                            Label("Delete", systemImage: "trash").labelStyle(.titleAndIcon)
                        }
                        .buttonStyle(CustomButtonRed())
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
                    .buttonStyle(CustomButtonGreen())
                }
            }
        }
    }
    
    var enterAppearance: some View {
        VStack(alignment: .leading) {
/*
            if appearanceEntered() {
                Button {
                    workAppearanceInternalID = sortedAppearances[0].internalID + 1
                    let verResult = VerifyAppearance.verifyAppearance(internalID: workAppearanceInternalID, appearDateTime: workAppearDateTime, appearNote: workAppearNote, appearReason: workAppearReason, representation: nil)
                    if verResult.errNo == 0 {
                        modelContext.insert(SDAppearance(internalID: workAppearanceInternalID, appearDateTime: workAppearDateTime, appearNote: workAppearNote, appearReason: workAppearReason, representation: rep))
                        do {
                            try modelContext.save()
                            addAppearanceFlag = false
                            initAppearance()
                            workAppearances = rep?.appearances?.sorted(by: { $0.appearDateTime < $1.appearDateTime } ) ?? []
                        } catch {
                            statusMessage = "Error inserting new appearance: \(error.localizedDescription)"
                        }
                        
                    } else {
                        statusMessage = "Error: \(verResult.errDescr)"
                    }
                } label: {
                    Label("Save Appearance", systemImage: "folder.badge.plus").labelStyle(.titleAndIcon)
                }
            }
*/
            HStack {
                Text("New Appearance:")
                Spacer() 
            }
            HStack {
                Text("Appearance Date:")
                DatePicker("", selection: $workAppearDateTime, displayedComponents: [.date]).onChange(of: workAppearDateTime, initial: true, {
                        workAppearDate = DateService.dateDate2String(inDate:    workAppearDateTime, short:true)
                    })
                HStack {
                    Picker("Appearance Time:",
                           selection: $workAppearTime) {
                        Text("0900")
                            .tag("0900")
                        Text("1315")
                            .tag("1315")
                    }.onChange(of: workAppearTime, initial: true, { workAppearDateTime = DateService.shortDateTime2String(inDate: workAppearDate, inTime: workAppearTime) } )
                }
            }//.padding(.trailing, proxy.size.width * 0.3)
            HStack {
                Text("Note:")
                TextField("", text: $workAppearNote)
            }
            HStack {
                Text("Reason")
                Picker("", selection: $workAppearReason) {
                    ForEach(AppearanceTypes.appearanceTypes, id: \.self) {
                        Text($0)
                    }
//                    .onChange(of: workAppearReason) { oldValue, newValue in
//                        print(workAppearReason)
//                        print("Changing from \(oldValue) to \(newValue)")
//                        print(workAppearReason)
//                    }

                }
                Text(AppearanceTypes.xlateType(inType: workAppearReason).descr)
            }.padding(.trailing, 15)
            if appearanceEntered() {
                HStack {
                    Spacer()
                    Button {
                        workAppearanceInternalID = sortedAppearances[0].internalID + 1
                        let verResult = VerifyAppearance.verifyAppearance(internalID: workAppearanceInternalID, appearDateTime: workAppearDateTime, appearNote: workAppearNote, appearReason: workAppearReason, representation: nil)
                        if verResult.errNo == 0 {
                            modelContext.insert(SDAppearance(internalID: workAppearanceInternalID, appearDateTime: workAppearDateTime, appearNote: workAppearNote, appearReason: workAppearReason, representation: rep))
                            do {
                                try modelContext.save()
                                addAppearanceFlag = false
                                initAppearance()
                                workAppearances = rep?.appearances?.sorted(by: { $0.appearDateTime < $1.appearDateTime } ) ?? []
                            } catch {
                                statusMessage = "Error inserting new appearance: \(error.localizedDescription)"
                            }
                            
                        } else {
                            statusMessage = "Error: \(verResult.errDescr)"
                        }
                    } label: {
                        Label("Save Appearance", systemImage: "folder.badge.plus").labelStyle(.titleAndIcon)
                    }
                    .buttonStyle(CustomButtonGreen())
                }.padding(.top, 15)
            }

        }
    }
    
    func returnAppearance(reqID: Int) -> (status: Bool, appr: SDAppearance?) {
        var workAppr: SDAppearance? = nil
        var status: Bool = false
        
        for ap in rep?.appearances ?? [] {
            if ap.internalID == reqID {
                workAppr = ap
                status = true
                break
            }
        }
        return (status, workAppr)
    }
    
    func resetCause(cause:SDCause?) {
        workCauseInternalID = cause?.internalID ?? -1
        workCauseCauseNo = cause?.causeNo ?? ""
        workCauseCauseType = cause?.causeType ?? ""
        workCauseLevel = cause?.level ?? ""
        workCauseCourt = cause?.court ?? ""
        workCauseOriginalCharge = cause?.originalCharge ?? ""
    }
    
    func initAppearance() {
        workAppearDateTime = Date.now
        workAppearDate = DateService.dateDate2String(inDate: workAppearDateTime, short:true)
        workAppearTime = "0900"
        workAppearNote = ""
        workAppearReason = "UNK"
        startAppearDateTime = Date.now
        startAppearDate = workAppearDate
        startAppearTime = "0900"
        startAppearNote = ""
        startAppearReason = "UNK"
    }

    func appearanceEntered() -> Bool {
        if workAppearDate != startAppearDate { return true }
        if workAppearTime != startAppearTime { return true }
        if workAppearNote != startAppearNote { return true }
        if workAppearReason != startAppearReason { return true }
        return false
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
            
            
            workInternalID =  -1
            workActive = true
            workAssignedDateTime = Date()
            workDispositionDateTime = Date.distantFuture
            workDispositionType = "UNK"
            workDispositionAction = "UNK"
            workPrimaryCategory = "UNK"
            workCause = SDCause()
            workClient = nil
            workAppearances = []
            workNotes = []
            
            resetCause(cause: workCause)
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
                
                workInternalID = representation.internalID
                workActive = representation.active
                workAssignedDateTime = representation.assignedDateTime
                workDispositionDateTime = representation.dispositionDateTime
                workDispositionType = representation.dispositionType
                workDispositionAction = representation.dispositionAction
                workPrimaryCategory = representation.primaryCategory
                workCause = representation.cause ?? SDCause()
                if let tempClient = representation.client {
                    workClient = tempClient
                } else if let tempClient = representation.cause?.client {
                    workClient = tempClient
                } else {
                    workClient = nil
                }
                workAppearances = representation.appearances?.sorted(by: { $0.appearDateTime < $1.appearDateTime } ) ?? []
                workNotes = representation.notes?.sorted(by: { $0.noteDateTime < $1.noteDateTime } ) ?? []
                
                resetCause(cause: workCause)
                addAppearanceFlag = false
            }
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

struct apprLine: View {
    var appr: SDAppearance
    var body: some View {
        VStack(alignment: .leading) {
            GeometryReader { geo in
                HStack {
                    Button(action: {
                        print("button: \(appr.internalID)")
                    }) {
                        Text("\(appr.internalID)")
                            .frame(width: geo.size.width * 0.05, alignment: .leading)
                    }
                    .buttonStyle(CustomButtonBlack())
                    Text(appr.appearDate)
                        .frame(width: geo.size.width * 0.09, alignment: .leading)
                    Text(appr.appearTime)
                        .frame(width: geo.size.width * 0.05, alignment: .leading)
                    Text(appr.appearReason)
                        .frame(width: geo.size.width * 0.05, alignment: .leading)
                    Text(appr.appearNote)
                        .frame(alignment: .leading)
                }
                .frame(height: 40)
            }
        }
    }
}

//#Preview {
//    EditRepresentation()
//}
