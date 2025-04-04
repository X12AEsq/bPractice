//
//  EditAppearance.swift
//  bLawPractice
//
//  Created by Morris Albers on 11/24/24.
//

import SwiftUI
import SwiftData

struct EditAppearance: View {
    @Environment(\.modelContext) var modelContext
    @EnvironmentObject var CVModel:CommonViewModel
    @EnvironmentObject var nav: NavigationStateManager
    
    @Query(sort: [SortDescriptor(\SDAppearance.internalID, order: .reverse)]) var sortedAppearances: [SDAppearance]
    
    @State var startInternalID: Int = -1
    @State var startRepresentation: SDRepresentation?
    @State var startAppearDateTime: Date = Date.distantPast
    @State var startAppearDate: String = ""
    @State var startAppearTime: String = ""
    @State var startAppearNote: String = ""
    @State var startAppearReason: String = ""

    @State var workInternalID: Int = -1
    @State var workRepresentation: SDRepresentation?
    @State var workAppearDateTime: Date = Date.distantPast
    @State var workAppearDate: String = ""
    @State var workAppearTime: String = ""
    @State var workAppearNote: String = ""
    @State var workAppearReason: String = "UNK"

    @State var deleteFlag:Bool = false

    @State var statusMessage:String = ""

    @State var workOption:String = ""
    @State var workAppearance: SDAppearance? = nil
    
    @State var is0900: Bool = false
    @State var is1315: Bool = false
    @State var isCustom: Bool = false
    @State var appearTime: String = ""
    
    var option:String
    var practice: SDPractice
    var representation: SDRepresentation?
    var appearance: SDAppearance?
    
    var body: some View {
        VStack(alignment: .leading) {
            GeometryReader { proxy in
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
                    Section(header: Text("Parents").background(Color.teal).foregroundColor(.white).font(.system(size: 20))) {
                        HStack {
                            Text("\(repString(rep: representation).rep)")
                        }
                        HStack {
                            Text("\(repString(rep: representation).cause)")
                        }
                        HStack {
                            Text("\(repString(rep: representation).client)")
                        }
                    }
                    Section(header: Text("Appearance").background(Color.teal).foregroundColor(.white).font(.system(size: 20))) {
                        // TODO: Finish assembling the actual date
                        //                    HStack {
                        //                        HStack {
                        //                            Text("Appearance Date: \(workAppearDate)")
                        //                            Text("Appearance Time: \(workAppearTime)")
                        //                        }
                        //                    }
                        
                        HStack {
                            Text("Appearance Date:").frame(width: proxy.size.width * 0.25)
                            DatePicker("", selection: $workAppearDateTime, displayedComponents: [.date]).onChange(of: workAppearDateTime, initial: true, {         workAppearDate = DateService.dateDate2String(inDate: workAppearDateTime, short:true) }).frame(width: proxy.size.width * 0.2)
                            HStack {
                                Picker("Appearance Time:",
                                       selection: $workAppearTime) {
                                    Text("0900")
                                        .tag("0900")
                                    Text("1315")
                                        .tag("1315")
                                }.onChange(of: workAppearTime, initial: true, { workAppearDateTime = DateService.shortDateTime2String(inDate: workAppearDate, inTime: workAppearTime) } ).frame(width: proxy.size.width * 0.2)
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
                        }.padding(.trailing, proxy.size.width * 0.5)
                    }
                }
            }
        }
        .onFirstAppear {
            initWorkArea()
        }
        .toolbar {
            if workOption != "Add" {
                if deleteFlag {
                    Button {
                        print("delete this")
                        deleteFlag = false
                        modelContext.delete(appearance!)
                        do {
                            try modelContext.save()
                            workOption = "Add"
                            CVModel.selectedAppearance = nil
                            workAppearance = nil
                            statusMessage = ""
                            initWorkArea()
                            if nav.selectionPath.count > 0 {
                                nav.selectionPath.removeLast()
                            }
                        } catch {
                            statusMessage = "Error deleting appearance: \(error.localizedDescription)"
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
            
            if appearanceModified() {
                Button {
                    let verResult = VerifyAppearance.verifyAppearance(internalID: workInternalID, appearDateTime: workAppearDateTime, appearNote: workAppearNote, appearReason: workAppearReason, representation: nil)
                    if verResult.errNo == 0 {
                        statusMessage = ""
                        if workOption == "Add" {
                            var workingInternalID = 0
                            
                            if sortedAppearances.count > 0 {
                                workingInternalID = sortedAppearances[0].internalID + 1
                            } else {
                                workingInternalID = 1
                            }
                            
                            if workingInternalID > 0 {
                                modelContext.insert(SDAppearance(internalID: workingInternalID, appearDateTime: workAppearDateTime, appearNote: workAppearNote, appearReason: workAppearReason, representation: workRepresentation))
                                do {
                                    try modelContext.save()
                                    let insertStatus = fetchAppearance(apprID: workingInternalID)
                                    if insertStatus.status {
                                        CVModel.selectedAppearance = insertStatus.appr
                                        statusMessage = ""
                                        if nav.selectionPath.count > 0 {
                                            nav.selectionPath.removeLast()
                                        }
                                        //                                            initWorkArea()
                                    } else {
                                        statusMessage = "Error inserting new appearance: \(insertStatus.message)"
                                    }
                                } catch {
                                    statusMessage = "Error inserting new appearance: \(error.localizedDescription)"
                                }
                            } else {
                                statusMessage = "Error assigning new appearance id number"
                            }
                        } else {    // end of option-Add
                            workAppearance?.internalID = workInternalID
                            workAppearance?.representation = workRepresentation
                            workAppearance?.appearDateTime = workAppearDateTime
                            workAppearance?.appearNote = workAppearNote
                            workAppearance?.appearReason = workAppearReason
                            do {
                                try modelContext.save()
                                CVModel.selectedAppearance?.appearDateTime = workAppearDateTime
                                CVModel.selectedAppearance?.appearNote = workAppearNote
                                CVModel.selectedAppearance?.appearReason = workAppearReason
                                CVModel.selectedAppearance?.representation = workRepresentation
                                statusMessage = ""
                                if nav.selectionPath.count > 0 {
                                    nav.selectionPath.removeLast()
                                }
                            } catch {
                                statusMessage = "Error updating appearance: \(error.localizedDescription)"
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
    
    func repString(rep: SDRepresentation?) -> (client: String, cause: String, rep: String) {
        if let workRep: SDRepresentation = rep {
            let repClient: String = "Client: \(workRep.client?.fullName ?? "No Name")"
            let repCause: String = "Cause: \(workRep.cause?.causeNo ?? "No Cause") \(rep?.cause?.originalCharge ?? "No Charge")"
            let rtnString = "Representation: \(DateService.dateDate2String(inDate:workRep.assignedDateTime, short:false)) \(rep?.primaryCategory ?? "No Representation")"
            return (client: repClient, cause: repCause, rep: rtnString)
        }
        return (client: "No representation", cause: "No representation", rep: "No representation")
    }
    
    func initWorkArea() {
        workOption = option
        workAppearance = appearance
        if workOption == "Add" {
            startInternalID = -1
            startRepresentation = representation
            startAppearDateTime = Date()
            startAppearDate = DateService.dateDate2String(inDate: startAppearDateTime, short:true)
            startAppearTime = DateService.dateTime2String(inDate: startAppearDateTime)
            startAppearNote = ""
            startAppearReason = "UNK"
            is0900 = true
            is1315 = false
            isCustom = false
        } else {
            startInternalID = workAppearance?.internalID ?? -1
            startRepresentation = representation
            startAppearDateTime = workAppearance?.appearDateTime ?? Date.distantPast
            startAppearDate = DateService.dateDate2String(inDate: startAppearDateTime, short:true)
            startAppearTime = DateService.dateTime2String(inDate: startAppearDateTime)
            startAppearNote = workAppearance?.appearNote ?? ""
            startAppearReason = workAppearance?.appearReason ?? "UNK"
            if DateService.dateTime2String(inDate: startAppearDateTime) == "0900" {
                is0900 = true
                is1315 = false
                isCustom = false
            } else {
                if DateService.dateTime2String(inDate: startAppearDateTime) == "1315" {
                    is0900 = false
                    is1315 = true
                    isCustom = false
                } else {
                    is0900 = false
                    is1315 = true
                    isCustom = true
                }
            }
        }
        
        workInternalID = startInternalID
        workRepresentation = startRepresentation
        workAppearDateTime = startAppearDateTime
        workAppearDate = startAppearDate
        workAppearTime = startAppearTime
        workAppearNote = startAppearNote
        workAppearReason = startAppearReason
    }
    
    func appearanceModified() -> Bool {
        if workInternalID != startInternalID { return true }
        if workAppearDateTime != startAppearDateTime { return true }
        if workAppearNote != startAppearNote { return true }
        if workAppearReason != startAppearReason { return true }
        if workRepresentation != startRepresentation { return true }
        return false
    }
    
    func fetchAppearance(apprID: Int) -> (status:Bool, message:String, appr:SDAppearance?) {
        if apprID < 1 { return (status: false, message: "Appearance \(apprID) is invalid", appr:nil) }
        let candidates:[SDAppearance] = sortedAppearances.filter({ $0.internalID == apprID })
        switch candidates.count {
        case 0:
            return (status: false, message: "Appearance \(apprID) was not found", appr:nil)
        case 1:
            return (status: true, message: "Appearance \(apprID) found", appr:candidates[0])
        default:
            return (status: false, message: "Appearance \(apprID) has duplicates", appr:nil)
        }
    }

    func moduleTitle() -> String {
        let prName = practice.name ?? "Unidentified Practice"
        return "\(prName) \(option) Appearance"
    }
}

//#Preview {
//    EditAppearance()
//}
