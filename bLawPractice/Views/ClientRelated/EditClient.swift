//
//  EditClient.swift
//  bLawPractice
//
//  Created by Morris Albers on 11/19/24.
//

import SwiftUI
import SwiftData

struct EditClient: View {
    @Environment(\.modelContext) var modelContext
    @EnvironmentObject var CVModel:CommonViewModel
    @EnvironmentObject var nav: NavigationStateManager

    @Query(sort: [SortDescriptor(\SDClient.internalID, order: .reverse)]) var sortedClients: [SDClient]
    
    @State var workInternalID: Int = -1
    @State var workLastName: String = ""
    @State var workFirstName: String = ""
    @State var workMiddleName: String = ""
    @State var workSuffix: String = ""
    @State var workAddr1: String = ""
    @State var workAddr2: String = ""
    @State var workCity: String = ""
    @State var workState: String = "TX"
    @State var workZip: String = ""
    @State var workPhone: String = ""
    @State var workAreacode: String = ""
    @State var workExchange: String = ""
    @State var workNumber: String = ""
    @State var workNote: String = ""
    @State var workMiscDocketDate: Date = Date.init(timeIntervalSince1970: 0)
    @State var workMiscDocketTime: String = "0900"

    @State var startInternalID: Int = -1
    @State var startLastName: String = ""
    @State var startFirstName: String = ""
    @State var startMiddleName: String = ""
    @State var startSuffix: String = ""
    @State var startAddr1: String = ""
    @State var startAddr2: String = ""
    @State var startCity: String = ""
    @State var startState: String = "TX"
    @State var startZip: String = ""
    @State var startPhone: String = ""
    @State var startAreacode: String = ""
    @State var startExchange: String = ""
    @State var startNumber: String = ""
    @State var startNote: String = ""
    @State var startMiscDocketDate: Date = Date.init(timeIntervalSince1970: 0)
    @State var startMiscDocketTime: String = "0900"

    @State var deleteFlag:Bool = false

    @State var statusMessage:String = ""
    @State var workOption:String = ""

    var practice: SDPractice
    var option: String
    var client: SDClient?

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                Text(moduleTitle())
                    .font(.system(size: 20))
                    .padding(.leading, 30)
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
                Section(header: Text("Client Name \(workInternalID)").background(Color.teal).foregroundColor(.white)) {
                    HStack {
                        Text("Last Name: ").foregroundColor(.mint)
                        TextField("Last Name", text: $workLastName).disableAutocorrection(true)
                    }
                    HStack {
                        Text("First Name: ").foregroundColor(.mint)
                        TextField("First Name", text: $workFirstName).disableAutocorrection(true)
                    }
                    HStack {
                        Text("Middle Name: ").foregroundColor(.mint)
                        TextField("Middle Name", text:$workMiddleName).disableAutocorrection(true)
                    }
                    HStack {
                        Text("Suffix: ").foregroundColor(.mint)
                        TextField("Suffix", text:$workSuffix).disableAutocorrection(true)
                    }
                }
                Section(header: Text("Address").background(Color.teal).foregroundColor(.white)) {
                    HStack {
                        Text("Address 1: ").foregroundColor(.mint)
                        TextField("Address Line 1", text: $workAddr1).disableAutocorrection(true)
                    }
                    HStack {
                        Text("Address 2: ").foregroundColor(.mint)
                        TextField("Address Line 2", text: $workAddr2).disableAutocorrection(true)
                    }
                    HStack {
                        Text("City: ").foregroundColor(.mint)
                        TextField("City", text: $workCity).disableAutocorrection(true)
                    }
                    Picker("State", selection: $workState) {
                        ForEach(ListOfStates.stateOptions, id: \.self) {
                            Text($0)
                        }
                    }
                    HStack {
                        Text("Zip: ").foregroundColor(.mint)
                        TextField("Zip", text:$workZip)
                    }
                }
                Section(header: Text("PHONE").background(Color.teal).foregroundColor(.white)) {
                    HStack {
                        Text("Area Code: ").foregroundColor(.mint)
                        TextField("Area", text: $workAreacode)
                    }
                    HStack {
                        Text("Exchange: ").foregroundColor(.mint)
                        TextField("Exchange", text: $workExchange)
                    }
                    HStack {
                        Text("Number: ").foregroundColor(.mint)
                        TextField("Number", text: $workNumber)
                        Spacer()
                    }
                }
                Section(header: Text("MISC").background(Color.teal).foregroundColor(.white)) {
                    VStack {
                        Text("Misc Docket \(workMiscDocketDate.formatted(date: .long, time: .omitted))")
                        Text("Misc Docket \(workMiscDocketTime)")
                        DatePicker(selection: $workMiscDocketDate, in: ...Date.now, displayedComponents: .date) {
                            Text("Select a date")
                        }
                        Picker("Select a time", selection: $workMiscDocketTime) {
                            ForEach(["0900", "1315"], id: \.self) {
                                Text($0)
                            }
                        }
                    }
                }
            }
            .onAppear(perform: {
                initWorkArea()
            })
        }
        .toolbar {
            if option != "Add" {
                if deleteFlag {
                    Button {
                        print("delete this")
                        deleteFlag = false
                        modelContext.delete(CVModel.selectedClient!)
                        do {
                            try modelContext.save()
                            workOption = "Add"
                            CVModel.selectedClient = nil
//                            workAppearance = nil
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

            if clientModified() {
                Button {
                    let verResult = VerifyClient.verifyClient(lastName: workLastName, firstName: workFirstName, middleName: workMiddleName, suffix: workSuffix, addr1: workAddr1, addr2: workAddr2, city: workCity, state: workState, zip: workZip, phone: TelephoneManager.assembleNumber(areaCode: workAreacode, exchange: workExchange, number: workNumber), practice: practice)
                    if verResult.errNo == 0 {
                        statusMessage = ""
                        if option == "Add" {
                            var workingInternalID = 0
                            
                            if sortedClients.count > 0 {
                                workingInternalID = sortedClients[0].internalID ?? 0
                                workingInternalID += 1
                            } else {
                                workingInternalID = 1
                            }

                            if workingInternalID > 0 {
                                CVModel.selectedClient = SDClient(internalID: workingInternalID, lastName: workLastName, firstName: workFirstName, middleName: workMiddleName, suffix: workSuffix, addr1: workAddr1, addr2: workAddr2, city: workCity, state: workState, zip: workZip, phone: TelephoneManager.assembleNumber(areaCode: workAreacode, exchange: workExchange, number: workNumber), note: workNote, miscDocketDate: DateService.dateString2Date(inDate:workMiscDocketDate, inTime:workMiscDocketTime), practice: practice)
                                modelContext.insert(CVModel.selectedClient!)
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
                            CVModel.selectedClient?.lastName = workLastName
                            CVModel.selectedClient?.firstName = workFirstName
                            CVModel.selectedClient?.middleName = workMiddleName
                            CVModel.selectedClient?.suffix = workSuffix
                            CVModel.selectedClient?.addr1 = workAddr1
                            CVModel.selectedClient?.addr2 = workAddr2
                            CVModel.selectedClient?.city = workCity
                            CVModel.selectedClient?.state = workState
                            CVModel.selectedClient?.zip = workZip
                            CVModel.selectedClient?.phone = TelephoneManager.assembleNumber(areaCode: workAreacode, exchange: workExchange, number: workNumber)
                            CVModel.selectedClient?.note = workNote
                            CVModel.selectedClient?.miscDocketDate = DateService.dateString2Date(inDate:workMiscDocketDate, inTime:workMiscDocketTime)
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
    
    func clientModified() -> Bool {
        if workInternalID != startInternalID { return true }
        if workLastName != startLastName { return true }
        if workFirstName != startFirstName { return true }
        if workMiddleName != startMiddleName { return true }
        if workSuffix != startSuffix { return true }
        if workAddr1 != startAddr1 { return true }
        if workAddr2 != startAddr2 { return true }
        if workCity != startCity { return true }
        if workState != startState { return true }
        if workZip != startZip { return true }
        if workPhone != startPhone { return true }
        if workAreacode != startAreacode { return true }
        if workExchange != startExchange { return true }
        if workNumber != startNumber { return true }
        if workNote != startNote { return true }
        if workMiscDocketDate != startMiscDocketDate { return true }
        if workMiscDocketTime != startMiscDocketTime { return true }
        return false
    }

    func initWorkArea() {
        workOption = option
        if workOption == "Add" {
            startInternalID = -1
            startLastName = ""
            startFirstName = ""
            startMiddleName = ""
            startSuffix = ""
            startAddr1 = ""
            startAddr2 = ""
            startCity = ""
            startState = "TX"
            startZip = ""
            startPhone = ""
            startAreacode = ""
            startExchange = ""
            startNumber = ""
            startNote = ""
            startMiscDocketDate = Date.init(timeIntervalSince1970: 0)
            startMiscDocketTime = "0900"
            CVModel.selectedClient = nil
        } else {
            CVModel.selectedClient = client
            startInternalID = client?.internalID ?? -1
            startLastName = client?.lastName ?? ""
            startFirstName = client?.firstName ?? ""
            startMiddleName = client?.middleName ?? ""
            startSuffix = client?.suffix ?? ""
            startAddr1 = client?.addr1 ?? ""
            startAddr2 = client?.addr2 ?? ""
            startCity = client?.city ?? ""
            startState = client?.state ?? ""
            startZip = client?.zip ?? ""
            startPhone = client?.phone ?? ""
            startAreacode = TelephoneManager.deComposePhone(inpphone: startPhone)[0]
            startExchange = TelephoneManager.deComposePhone(inpphone: startPhone)[1]
            startNumber = TelephoneManager.deComposePhone(inpphone: startPhone)[2]
            startNote = client?.note ?? ""
            startMiscDocketDate = client?.miscDocketDate ?? Date.distantPast
            startMiscDocketTime = DateService.dateTime2String(inDate: startMiscDocketDate)
            CVModel.selectedClient = client
        }
        workInternalID = startInternalID
        workLastName = startLastName
        workFirstName = startFirstName
        workMiddleName = startMiddleName
        workSuffix = startSuffix
        workAddr1 = startAddr1
        workAddr2 = startAddr2
        workCity = startCity
        workState = startState
        workZip = startZip
        workPhone = startPhone
        workAreacode = startAreacode
        workExchange = startExchange
        workNumber = startNumber
        workNote = startNote
        workMiscDocketDate = startMiscDocketDate
        workMiscDocketTime = startMiscDocketTime
    }
    
    func moduleTitle() -> String {
        let prName = practice.name ?? "Unidentified Practice"
        return "\(prName) \(option) Client"
    }

}

//#Preview {
//    EditClient()
//}
