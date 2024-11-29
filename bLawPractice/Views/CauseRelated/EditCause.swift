//
//  EditCause.swift
//  bLawPractice
//
//  Created by Morris Albers on 11/20/24.
//

import SwiftUI
import SwiftData

struct EditCause: View {
    @Environment(\.modelContext) var modelContext
    @EnvironmentObject var CVModel:CommonViewModel
    @EnvironmentObject var nav: NavigationStateManager
    
    @Query(sort: [SortDescriptor(\SDCause.causeNo)]) var sortedCauses: [SDCause]

    @State var startInternalID:Int = -1
    @State var startCauseNo:String = ""
    @State var startCauseType:String = ""
    @State var startCauseLevel:String = ""
    @State var startCauseCourt:String = ""
    @State var startOriginalCharge: String = ""
    @State var startClient:SDClient? = nil
    @State var startClientID:Int = -1
    @State var startClientFullName:String = ""
    @State var startClientLastName:String = ""
    @State var startClientFirstName:String = ""
    @State var startClientMiddleName:String = ""
    @State var startClientSuffix:String = ""

    @State var workInternalID:Int = -1
    @State var workCauseNo:String = ""
    @State var workCauseType:String = ""
    @State var workCauseLevel:String = ""
    @State var workCauseCourt:String = ""
    @State var workOriginalCharge: String = ""
    @State var workClient:SDClient? = nil
    @State var workClientID:Int = -1
    @State var workClientFullName:String = ""
    @State var workClientLastName:String = ""
    @State var workClientFirstName:String = ""
    @State var workClientMiddleName:String = ""
    @State var workClientSuffix:String = ""
    
    @State var deleteFlag:Bool = false

    @State var statusMessage:String = ""
    
    var practice: SDPractice
    var option: String
    var cause: SDCause?

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
                Section(header: Text("Cause").background(Color.teal).foregroundColor(.white).font(.system(size: 20))) {
                    HStack {
                        Text("Cause Number")
                        TextField("", text: $workCauseNo).disableAutocorrection(true)
                    }
                    Picker("CauseType", selection: $workCauseType) {
                        ForEach(CauseTypeOptions.causeTypeOptions, id: \.self) {
                            Text($0)
                        }
                    }
                    Picker("Cause Level", selection: $workCauseLevel) {
                        ForEach(OffenseOptions.offenseOptions, id: \.self) {
                            Text($0)
                        }
                    }
                    .onChange(of: workCauseLevel) {
                        if workCauseLevel == "SJF" || workCauseLevel == "F-1" || workCauseLevel == "F-2" || workCauseLevel == "F-3" || workCauseLevel == "F-*" || workCauseLevel == "CPS" {
                            workCauseCourt = "155th"
                        } else {
                            if workCauseLevel != "UNK" {
                                workCauseCourt = "CC"
                            }
                        }
                    }
                    Picker("Court", selection: $workCauseCourt) {
                        ForEach(AvailableCourts.courtOptions, id: \.self)  {
                            Text($0)
                        }
                    }
                    HStack {
                        Text("Charge")
                        TextField("", text: $workOriginalCharge).disableAutocorrection(true)
                    }
                }
                Section {
                    //                Section(header:
                    //                    Text("Client").background(Color.teal).foregroundColor(.white).font(.system(size: 20))) {
                    NavigationLink("Change Client", value: NavSelectClient(selectionArgument: "inq"))
                    //                        .font(.system(size: 30))
                    
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Name: \(workClientLastName), \(workClientFirstName), \(workClientMiddleName), \(workClientSuffix)")
                            HStack {
                                Text("Address 1: \(cause?.client?.addr1 ?? "")")
                            }
                            HStack {
                                Text("Address 2: \(cause?.client?.addr2 ?? "")")
                            }
                            HStack {
                                Text("City: \(cause?.client?.city ?? "") \(cause?.client?.state ?? "") \(cause?.client?.zip ?? "")")
                            }
                            HStack {
                                Text("Telephone: \(cause?.client?.phone ?? "")")
                            }
                        }
                    }
                    
                }
                .onAppear(perform: {
                    workClientID = CVModel.selectedClient?.internalID ?? -1
                    workClientFullName = CVModel.selectedClient?.fullName ?? "No Client"
                    workClientLastName = CVModel.selectedClient?.lastName ?? ""
                    workClientFirstName = CVModel.selectedClient?.firstName ?? ""
                    workClientMiddleName = CVModel.selectedClient?.middleName ?? ""
                    workClientSuffix = CVModel.selectedClient?.suffix ?? ""
                    workClient = CVModel.selectedClient
                })
                .onFirstAppear {
                    initWorkArea()
                }
            }
            .toolbar {
                if option != "Add" {
                    if deleteFlag {
                        Button {
                            print("delete this")
                            deleteFlag = false
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

                if causeModified() {
                    Button {
                        let verResult = VerifyCause.verifyCause(internalID: workInternalID, causeNo: workCauseNo, causeType: workCauseType, level: workCauseLevel, court: workCauseCourt, originalCharge: workOriginalCharge, client: workClient)
                        if verResult.errNo == 0 {
                            statusMessage = ""
                            if option == "Add" {
                                var workingInternalID = 0
                                
                                if sortedCauses.count > 0 {
                                    workingInternalID = sortedCauses[0].internalID
                                    workingInternalID += 1
                                } else {
                                    workingInternalID = 1
                                }

                                if workingInternalID > 0 {
                                    CVModel.selectedCause = SDCause(internalID: workingInternalID, causeNo: workCauseNo, causeType: workCauseType, level: workCauseLevel, court: workCauseCourt, originalCharge: workOriginalCharge, client: workClient)
                                    modelContext.insert(CVModel.selectedCause!)
                                    do {
                                        try modelContext.save()
                                            statusMessage = ""
                                            initWorkArea()
                                    } catch {
                                        statusMessage = "Error inserting new client: \(error.localizedDescription)"
                                    }
                                } else {
                                    statusMessage = "Error assigning new client number"
                                }
                            } else {    // end of option-Add
                                CVModel.selectedCause?.internalID = workInternalID
                                CVModel.selectedCause?.causeNo = workCauseNo
                                CVModel.selectedCause?.causeType = workCauseType
                                CVModel.selectedCause?.level = workCauseLevel
                                CVModel.selectedCause?.court = workCauseCourt
                                CVModel.selectedCause?.originalCharge = workOriginalCharge
                                CVModel.selectedCause?.client = workClient
                                CVModel.selectedCause?.practice = practice
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
    
    func initWorkArea() {
        if option == "Add" {
            startInternalID = -1
            startCauseNo = ""
            startCauseType = "UNK"
            startCauseCourt = "UNK"
            startCauseLevel = "UNK"
            startOriginalCharge = ""
            startClientID = -1
            startClientFullName = ""
            startClientLastName = ""
            startClientFirstName = ""
            startClientMiddleName = ""
            startClientSuffix = ""
            startClient = nil
        } else {
            startInternalID = cause?.internalID ?? -1
            startCauseNo = cause?.causeNo ?? ""
            startCauseType = cause?.causeType ?? "UNK"
            startCauseCourt = cause?.court ?? "UNK"
            startCauseLevel = cause?.level ?? "UNK"
            startOriginalCharge = cause?.originalCharge ?? ""
            startClientID = cause?.client?.internalID ?? -1
            startClientFullName = cause?.client?.fullName ?? "Error 1 Unwrapping Name"
            startClientLastName = cause?.client?.lastName ?? ""
            startClientFirstName = cause?.client?.firstName ?? ""
            startClientMiddleName = cause?.client?.middleName ?? ""
            startClientSuffix = cause?.client?.suffix ?? ""
            if let tempClient = cause?.client {
                startClient = tempClient
            } else {
                 startClient = CVModel.selectedCause?.client
            }
        }
        
        workInternalID = startInternalID
        workCauseNo = startCauseNo
        workCauseType = startCauseType
        workCauseCourt = startCauseCourt
        workCauseLevel = startCauseLevel
        workOriginalCharge = startOriginalCharge
        workClientID = startClientID
        workClientFullName = startClientFullName
        workClientLastName = ""
        workClientFirstName = ""
        workClientMiddleName = ""
        workClientSuffix = ""
        workClient = startClient
    }
    
    func causeModified() -> Bool {
        return (startInternalID != workInternalID) ||
        (startCauseNo != workCauseNo) ||
        (startCauseType != workCauseType) ||
        (startCauseCourt != workCauseCourt) ||
        (startCauseLevel != workCauseLevel) ||
        (startOriginalCharge != workOriginalCharge) ||
        (startClientID != workClientID)
    }

    func moduleTitle() -> String {
        let prName = practice.name ?? "Unidentified Practice"
        return "\(prName) \(option) Cause"
    }
}

//#Preview {
//    EditCause()
//}
