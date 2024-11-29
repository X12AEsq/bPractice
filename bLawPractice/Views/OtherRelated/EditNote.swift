//
//  EditNote.swift
//  bLawPractice
//
//  Created by Morris Albers on 11/24/24.
//

import SwiftUI
import SwiftData

struct EditNote: View {
    @Environment(\.modelContext) var modelContext
    @EnvironmentObject var CVModel:CommonViewModel
    @EnvironmentObject var nav: NavigationStateManager
    
    @Query(sort: [SortDescriptor(\SDNote.internalID, order: .reverse)]) var sortedNotes: [SDNote]
    
    @State var startInternalID: Int = -1
    @State var startRepresentation: SDRepresentation?
    @State var startNoteDateTime: Date = Date.distantPast
    @State var startNoteNote: String = ""
    @State var startNoteCategory: String = ""

    @State var workInternalID: Int = -1
    @State var workRepresentation: SDRepresentation?
    @State var workNoteDateTime: Date = Date.distantPast
    @State var workNoteNote: String = ""
    @State var workNoteCategory: String = ""

    @State var deleteFlag:Bool = false

    @State var statusMessage:String = ""

    @State var workOption:String = ""
    @State var workNote: SDNote? = nil
    
    var option:String
    var practice: SDPractice
    var representation: SDRepresentation?
    var note: SDNote?

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
                Section(header: Text("Note").background(Color.teal).foregroundColor(.white).font(.system(size: 20))) {
                    HStack {
                        Text("Note Date:")
                        DatePicker("", selection: $workNoteDateTime)
                    }
                    HStack {
                        Text("Note:")
                        TextField("", text: $workNoteNote)
                    }
                    HStack {
                        Text("Type")
                        Picker("", selection: $workNoteCategory) {
                            ForEach(NoteTypes.noteTypes, id: \.self) {
                                Text($0)
                            }
                        }
                        Text(AppearanceTypes.xlateType(inType: workNoteCategory).descr)
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
                        modelContext.delete(note!)
                        do {
                            try modelContext.save()
                            workOption = "Add"
                            CVModel.selectedNote = nil
                            workNote = nil
                            statusMessage = ""
                            initWorkArea()
                            if nav.selectionPath.count > 0 {
                                nav.selectionPath.removeLast()
                            }
                        } catch {
                            statusMessage = "Error deleting note: \(error.localizedDescription)"
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
            
            if noteModified() {
                Button {
                    let verResult = VerifyNote.verifyNote(internalID: workInternalID, noteDateTime: workNoteDateTime, noteNote: workNoteNote, noteCategory: workNoteCategory, representation: nil)
                    if verResult.errNo == 0 {
                        statusMessage = ""
                        if workOption == "Add" {
                            var workingInternalID = 0
                            
                            if sortedNotes.count > 0 {
                                workingInternalID = sortedNotes[0].internalID + 1
                            } else {
                                workingInternalID = 1
                            }
                            
                            if workingInternalID > 0 {
                                modelContext.insert(SDNote(internalID: workingInternalID, noteDateTime: workNoteDateTime, noteNote: workNoteNote, noteCategory: workNoteCategory, representation: workRepresentation))
                                do {
                                    try modelContext.save()
                                    let insertStatus = fetchNote(noteID: workingInternalID)
                                    if insertStatus.status {
                                        CVModel.selectedNote = insertStatus.note
                                        statusMessage = ""
                                        if nav.selectionPath.count > 0 {
                                            nav.selectionPath.removeLast()
                                        }
                                    } else {
                                        statusMessage = "Error inserting new note: \(insertStatus.message)"
                                    }
                                } catch {
                                    statusMessage = "Error inserting new Note: \(error.localizedDescription)"
                                }
                            } else {
                                statusMessage = "Error assigning new Note id number"
                            }
                        } else {    // end of option-Add
                            do {
                                try modelContext.save()
                                CVModel.selectedNote?.noteDateTime = workNoteDateTime
                                CVModel.selectedNote?.noteNote = workNoteNote
                                CVModel.selectedNote?.noteCategory = workNoteCategory
                                CVModel.selectedNote?.representation = workRepresentation
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
        workNote = note
        if workOption == "Add" {
            startInternalID = -1
            startRepresentation = representation
            startNoteDateTime = Date()
            let startNoteDate: String = DateService.dateDate2String(inDate:Date(), short:true)
            startNoteDateTime = DateService.shortDateTime2String(inDate: startNoteDate, inTime: "0900")
            startNoteNote = ""
            startNoteCategory = ""
        } else {
            startInternalID = workNote?.internalID ?? -1
            startRepresentation = representation
            startNoteDateTime = workNote?.noteDateTime ?? Date.distantPast
            startNoteNote = ""
            startNoteCategory = ""
        }
        
        workInternalID = startInternalID
        workRepresentation = startRepresentation
        workNoteDateTime = startNoteDateTime
        workNoteNote = startNoteNote
        workNoteCategory = startNoteCategory
    }
    
    func noteModified() -> Bool {
        if workInternalID != startInternalID { return true }
        if workNoteDateTime != startNoteDateTime { return true }
        if workNoteNote != startNoteNote { return true }
        if workNoteCategory != startNoteCategory { return true }
        if workRepresentation != startRepresentation { return true }
        return false
    }
    
    func fetchNote(noteID: Int) -> (status:Bool, message:String, note:SDNote?) {
        if noteID < 1 { return (status: false, message: "Note \(noteID) is invalid", note:nil) }
        let candidates:[SDNote] = sortedNotes.filter({ $0.internalID == noteID })
        switch candidates.count {
        case 0:
            return (status: false, message: "Note \(noteID) was not found", note:nil)
        case 1:
            return (status: true, message: "Note \(noteID) found", note:candidates[0])
        default:
            return (status: false, message: "Note \(noteID) has duplicates", note:nil)
        }
    }

    func moduleTitle() -> String {
        let prName = practice.name ?? "Unidentified Practice"
        return "\(prName) \(option) Note"
    }
}

//#Preview {
//    EditNote()
//}
