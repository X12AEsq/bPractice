//
//  ContentViewRestoreExtension.swift
//  bLawPractice
//
//  Created by Morris Albers on 11/17/24.
//

import Foundation

extension ContentView {
    func restoreData() {
        CVModel.restoreReport = ""
        let fileContents = readFile()
        let backupArray: [String] = fileContents.components(separatedBy: "\n")
        print("")
/*
        do {
            try modelContext.delete(model: SDPractice.self)
            try modelContext.save()
        } catch {
            let rptLine: String = "Failed to delete practices \(error.localizedDescription)"
            print(rptLine)
            CVModel.restoreReport += "\(rptLine)\n"
        }

        handlePractices(fileContents: backupArray.filter( { $0.hasPrefix("SDP") } ))

        do {
            try modelContext.delete(model: SDClient.self)
            try modelContext.save()
        } catch {
            let rptLine: String = "Failed to delete clients \(error.localizedDescription)"
            print(rptLine)
            CVModel.restoreReport += "\(rptLine)\n"
        }
        
        handleClients(fileContents: backupArray.filter( { $0.hasPrefix("SCL") } ))

        do {
            try modelContext.delete(model: SDCause.self)
            try modelContext.save()
        } catch {
            let rptLine: String = "Failed to delete causes \(error.localizedDescription)"
            print(rptLine)
            CVModel.restoreReport += "\(rptLine)\n"
        }
        
        handleCauses(fileContents: backupArray.filter( { $0.hasPrefix("SCA") } ))

        do {
            try modelContext.delete(model: SDRepresentation.self)
            try modelContext.save()
        } catch {
            let rptLine: String = "Failed to delete representations \(error.localizedDescription)"
            print(rptLine)
            CVModel.restoreReport += "\(rptLine)\n"
        }
        
        handleRepresentations(fileContents: backupArray.filter( { $0.hasPrefix("SRE") } ))

        handleAppearances(fileContents: backupArray.filter( { $0.hasPrefix("SAP") } ))

        do {
            try modelContext.delete(model: SDAppearance.self)
            try modelContext.save()
        } catch {
            let rptLine: String = "Failed to delete appearances \(error.localizedDescription)"
            print(rptLine)
            CVModel.restoreReport += "\(rptLine)\n"
        }
 */
        do {
            try modelContext.delete(model: SDNote.self)
            try modelContext.save()
        } catch {
            let rptLine: String = "Failed to delete notes \(error.localizedDescription)"
            print(rptLine)
            CVModel.restoreReport += "\(rptLine)\n"
        }
        
        handleNotes(fileContents: backupArray.filter( { $0.hasPrefix("SNO") } ))

        writeRestoreReport(fileContents: CVModel.restoreReport)
    }
    
    func handlePractices(fileContents: [String]) {
        var PRinternalId:Int
        var PRaddr1: String
        var PRaddr2: String
        var PRcity: String
        var PRname: String
        var PRshortName: String
        var PRstate: String
        var PRtesting: Bool
        var PRzip: String

        for line in fileContents {
            PRinternalId = 0
            PRaddr1 = ""
            PRaddr2 = ""
            PRcity = ""
            PRname = ""
            PRshortName = ""
            PRstate = ""
            PRtesting = false
            PRzip = ""
            
            let splitLine = splitLineOut(line: line)
            PRinternalId = Int(splitLine[1]) ?? -1
            PRaddr1 = splitLine[2]
            PRaddr2 = splitLine[3]
            PRcity = splitLine[4]
            PRname = splitLine[5]
            PRshortName = splitLine[6]
            PRstate = splitLine[7]
            PRtesting = splitLine[8] == "true"
            PRzip = splitLine[9]
            
            let PRPractice: SDPractice = SDPractice(addr1: PRaddr1, addr2: PRaddr2, city: PRcity, internalID: PRinternalId, name: PRname, shortName: PRshortName, state: PRstate, testing: PRtesting, zip: PRzip)
            
            modelContext.insert(PRPractice)
            do {
                try modelContext.save()
                if !PRtesting {
                    selected = PRPractice
                }
                CVModel.restoreReport += "inserted practice \(line): \(line)\n"
            } catch {
                let rptLine: String = "error inserting practice \(line): \(error.localizedDescription)"
                print(rptLine)
                CVModel.restoreReport += "\(rptLine)\n"
            }
            print("")
        }
    }
/*
    func handleClients(fileContents: [String]) {
        var CLinternalID: Int = -1
        var CLlastName: String = ""
        var CLfirstName: String = ""
        var CLmiddleName: String = ""
        var CLsuffix: String = ""
        var CLaddr1: String = ""
        var CLaddr2: String = ""
        var CLcity: String = ""
        var CLstate: String = ""
        var CLzip: String = ""
        var CLphone: String = ""
        var CLnote: String  = ""
        var CLmiscDocketDate: Date = .distantPast
        
        for line in fileContents {
            CLinternalID = 0
            CLlastName = ""
            CLfirstName = ""
            CLmiddleName = ""
            CLsuffix = ""
            CLaddr1 = ""
            CLaddr2 = ""
            CLcity = ""
            CLstate = ""
            CLzip = ""
            CLphone = ""
            CLnote = ""
            CLmiscDocketDate = Date.distantPast
            
            let splitLine = splitLineOut(line: line)
            CLinternalID = Int(splitLine[1]) ?? -1
            CLlastName = splitLine[2]
            CLfirstName = splitLine[3]
            CLmiddleName = splitLine[4]
            CLsuffix = splitLine[5]
            CLaddr1 = splitLine[6]
            CLaddr2 = splitLine[7]
            CLcity = splitLine[8]
            CLstate = splitLine[9]
            CLzip = splitLine[10]
            CLphone = splitLine[11]
            CLnote = splitLine[12]
            CLmiscDocketDate = DateService.dateString2Date(inDate:splitLine[13])
            let CLClient: SDClient = SDClient(internalID: CLinternalID, lastName: CLlastName, firstName: CLfirstName, middleName: CLmiddleName, suffix: CLsuffix, addr1: CLaddr1, addr2: CLaddr2, city: CLcity, state: CLstate, zip: CLzip, phone: CLphone, note: CLnote, miscDocketDate: CLmiscDocketDate)
            CLClient.practice = selected
            
            addClient(sdCLI: CLClient, sdCAU: nil, line: line)
            
            print("")
        }
    }
    
    func addClient(sdCLI: SDClient, sdCAU: SDCause?, line: String) {
        let clientCount: Int = clients.filter( { $0.internalID == sdCLI.internalID  } ).count
        if clientCount == 0 {
            modelContext.insert(sdCLI)
            do {
                try modelContext.save()
                CVModel.restoreReport += "inserted client: \(line)\n"
            } catch {
                let rptLine: String = "error inserting client \(line): \(error.localizedDescription)"
                print(rptLine)
                CVModel.restoreReport += "\(rptLine)\n"
            }
            return
        }
        
//        if let cause = sdCAU {
//            for i in 0..<clientCount - 1 {
//                if clients[i].internalID == sdCLI.internalID {
//                    checkCauseCLients(sdCLI: clients[i], sdCAU: cause, line: line)
//                    
//                }
//            }
//        }
    }
    
    func handleCauses(fileContents: [String]) {
        var workingLines:[String] = fileContents

        while workingLines.count > 0 {
            var CAinternalID: Int = -1
            var CAcauseNo: String = ""
            var CAcauseType: String = ""       //  Appointed/Private/Family
            var CAlevel: String = ""
            var CAcourt: String = ""
            var CAoriginalCharge: String = ""
            var cause: SDCause
            
            let splitLine = splitLineOut(line: workingLines[0])
            
            CAinternalID = Int(splitLine[1]) ?? -1
            CAcauseNo = splitLine[2]
            CAcauseType = splitLine[3]
            CAlevel = splitLine[4]
            CAcourt = splitLine[5]
            CAoriginalCharge = splitLine[6]
            
            cause = SDCause(internalID: CAinternalID, causeNo: CAcauseNo, causeType: CAcauseType, level: CAlevel, court: CAcourt, originalCharge: CAoriginalCharge)
            cause.practice = selected
            cause.client = nil
            if splitLine.count > 7 {
                let clientNr:Int = Int(splitLine[7]) ?? -1
                if clientNr > 0 {
                    cause.client = locateClient(reqClient: clientNr)
                }
            }
            modelContext.insert(cause)
            do {
                try modelContext.save()
                CVModel.restoreReport += "inserted cause: \(workingLines[0])\n"
            } catch {
                let rptLine: String = "error inserting cause \(workingLines[0]): \(error.localizedDescription)"
                print(rptLine)
                CVModel.restoreReport += "\(rptLine)\n"
            }

            workingLines.remove(at: 0)
        }
    }
*/
    func handleRepresentations(fileContents: [String]) {
        var workingLines:[String] = fileContents

        var REpractice:SDPractice? = nil
        
        if prodPractice.count > 0 {
            REpractice = prodPractice[0]
        }
        
        while workingLines.count > 0 {
            var REinternalID:Int = -1
            var REactive = false               // Open,Closed
            var REassignedDateTime: Date = Date.distantPast
            var REdispositionDateTime: Date = Date.distantPast
            var REdispositionType: String = ""     // PB, DISM, OTH ...
            var REdispositionAction:String = ""    // PROB, DEF, PTD, C ...
            var REprimaryCategory:String = ""     // ORIG, MTA, MTR, ...
            
            let splitLine = splitLineOut(line: workingLines[0])

            REinternalID = Int(splitLine[1]) ?? -1
            REactive = (splitLine[2] == "true")
            REassignedDateTime = DateService.shortDate2String(inDate: splitLine[3])
            REdispositionDateTime = DateService.shortDate2String(inDate: splitLine[4])
            REdispositionType = splitLine[5]
            REdispositionAction = splitLine[6]
            REprimaryCategory = splitLine[7]
            
            let REinvolvedClient:Int = Int(splitLine[8]) ?? -1
            let REinvolvedCause:Int = Int(splitLine[9]) ?? -1
            
            let REClient: SDClient? = locateClient(reqClient: REinvolvedClient)
            let RECause: SDCause? = locateCause(reqCause: REinvolvedCause)
            
            let RErepresentation:SDRepresentation = SDRepresentation(internalID: REinternalID, active: REactive, assignedDate: REassignedDateTime, dispositionDate: REdispositionDateTime, dispositionType: REdispositionType, dispositionAction: REdispositionAction, primaryCategory: REprimaryCategory, cause: RECause, client: REClient, appearances: [SDAppearance](), notes: [SDNote](), statussegs: [SDStatusSeg](), practice: REpractice)
            
            modelContext.insert(RErepresentation)
            do {
                try modelContext.save()
                CVModel.restoreReport += "inserted representation: \(workingLines[0])\n"
            } catch {
                let rptLine: String = "error inserting representation \(workingLines[0]): \(error.localizedDescription)"
                print(rptLine)
                CVModel.restoreReport += "\(rptLine)\n"
            }

            workingLines.remove(at: 0)
        }
    }

    func handleAppearances(fileContents: [String]) {
        var workingLines:[String] = fileContents

        var APpractice:SDPractice? = nil
        
        if prodPractice.count > 0 {
            APpractice = prodPractice[0]
        }
        
        var appearance: SDAppearance = SDAppearance()

        while workingLines.count > 0 {
//            - 1317 : "SAP^00001^20210203^0900^conversion^ORIG^1"
//            var internalID: Int = -1
//            var practice: SDPractice?
//            var representation: SDRepresentation?
//            var appearDateTime: Date = Date.distantPast
//            var appearNote: String = ""
//            var appearReason: String = ""
            let splitLine = splitLineOut(line: workingLines[0])

            let AinternalID: Int = Int(splitLine[1]) ?? -1
            if AinternalID > 0 {
                let AappearDate:String = splitLine[2]
                let AappearTime:String = splitLine[3]
                let AappearDateTime: Date = DateService.shortDateTime2String(inDate: AappearDate, inTime: AappearTime)
                let ANote: String = splitLine[4]
                let AReason: String = splitLine[5]
                let aRepID: Int = Int(splitLine[6]) ?? -1
                if let aRep: SDRepresentation = self.locateRepresentative(reqRep: aRepID) {
                    appearance = SDAppearance(internalID: AinternalID, appearDateTime: AappearDateTime, appearNote: ANote, appearReason: AReason, representation: aRep)
                    appearance.practice = APpractice
                    modelContext.insert(appearance)
                    do {
                        try modelContext.save()
                        CVModel.restoreReport += "inserted appearance: \(workingLines[0])\n"
                    } catch {
                        let rptLine: String = "error inserting appearance \(workingLines[0]): \(error.localizedDescription)"
                        print(rptLine)
                        CVModel.restoreReport += "\(rptLine)\n"
                    }
                } else {
                    CVModel.restoreReport += "error: appearance \(workingLines[0]) has no representation\n"
                }
            } else {
                CVModel.restoreReport += "error: appearance \(workingLines[0]) has no internal ID\n"
            }
            
            workingLines.remove(at: 0)
        }
    }
    
    func handleNotes(fileContents: [String]) {
//  SNO^00032^e-mail sent requesting status^20221207^1119^NOTE^200
/*
 var internalID: Int = -1
 var practice: SDPractice?
 var representation: SDRepresentation?
 var noteDateTime: Date = Date.distantPast
 var noteNote: String = ""
 var noteCategory: String = ""

 */
        var workingLines:[String] = fileContents
        
        var notePractice:SDPractice? = nil
        
        if prodPractice.count > 0 {
            notePractice = prodPractice[0]
        }
        
        var note: SDNote = SDNote()

        while workingLines.count > 0 {
            let splitLine = splitLineOut(line: workingLines[0])
            
            let noteInternalID: Int = Int(splitLine[1]) ?? -1
            if noteInternalID > 0 {
                let noteNote: String = splitLine[2]
                let noteNoteDate:String = splitLine[3]
                let noteNoteTime:String = splitLine[4]
                let noteNoteDateTime: Date = DateService.shortDateTime2String(inDate: noteNoteDate, inTime: noteNoteTime)
                let noteCategory: String = splitLine[5]
                let noteRepID: Int = Int(splitLine[6]) ?? -1
                if let noteRep: SDRepresentation = self.locateRepresentative(reqRep: noteRepID) {
                    note = SDNote(internalID: noteInternalID, noteDateTime: noteNoteDateTime, noteNote: noteNote, noteCategory: noteCategory, representation: noteRep)
                    note.practice = notePractice
                    modelContext.insert(note)
                    do {
                        try modelContext.save()
                        CVModel.restoreReport += "inserted note: \(workingLines[0])\n"
                    } catch {
                        let rptLine: String = "error inserting note \(workingLines[0]): \(error.localizedDescription)"
                        print(rptLine)
                        CVModel.restoreReport += "\(rptLine)\n"
                    }
                } else {
                    CVModel.restoreReport += "error: note \(workingLines[0]) has no representation\n"
                }
            } else {
                CVModel.restoreReport += "error: note \(workingLines[0]) has no internal ID\n"
            }
            
            workingLines.remove(at: 0)
        }
    }
/*
    func handleSingleCause(fileContents: [String]) {
        var workingLines:[String] = fileContents
        var cause: SDCause = SDCause()
        var client: SDClient = SDClient()
        var representation: SDRepresentation = SDRepresentation()
        var appearance: SDAppearance = SDAppearance()
        var note: SDNote = SDNote()
        
        var CAinternalID: Int = -1
        var CAcauseNo: String = ""
        var CAcauseType: String = ""       //  Appointed/Private/Family
        var CAlevel: String = ""
        var CAcourt: String = ""
        var CAoriginalCharge: String = ""
        
        var CLinternalID: Int = -1
        var CLlastName: String = ""
        var CLfirstName: String = ""
        var CLmiddleName: String = ""
        var CLsuffix: String = ""
        var CLaddr1: String = ""
        var CLaddr2: String = ""
        var CLcity: String = ""
        var CLstate: String = ""
        var CLzip: String = ""
        var CLphone: String = ""
        var CLnote: String  = ""
        var CLmiscDocketDate: Date = .distantPast
        
        var REinternalID: Int = -1
        var REactive: Bool = false               // Open,Closed
        var REassignedDateTime: Date = Date.distantPast
        var REdispositionDateTime: Date = Date.distantPast
        var REdispositionType: String = ""     // PB, DISM, OTH ...
        var REdispositionAction:String = ""    // PROB, DEF, PTD, C ...
        var REprimaryCategory:String = ""     // ORIG, MTA, MTR, ...
        
        var APinternalID: Int = -1
        var APappeardate: String = ""
        var APappearTime: String = ""
        var APappearDateTime: Date = Date.distantPast
        var APappearNote: String = ""
        var APappearReason: String = ""

        var NOinternalID: Int = -1
//        var NOappearDate: String
//        var NOappearTime: String
        var NOnoteDateTime: Date = Date.distantPast
        var NOnoteNote: String = ""
        var NOnoteCategory: String = ""
        
        while workingLines.count > 0 {
            let firstLine = workingLines[0]
            let splitLine = splitLineOut(line: firstLine)
            workingLines.remove(at: 0)
            
            if splitLine.count > 2 {
                if splitLine[2] == "SCL" { // this is the cause's client
                    CLinternalID = Int(splitLine[3]) ?? -1
                    CLlastName = splitLine[4]
                    CLfirstName = splitLine[5]
                    CLmiddleName = splitLine[6]
                    CLsuffix = splitLine[7]
                    CLaddr1 = splitLine[8]
                    CLaddr2 = splitLine[9]
                    CLcity = splitLine[10]
                    CLstate = splitLine[11]
                    CLzip = splitLine[12]
                    CLphone = splitLine[13]
                    CLnote = splitLine[14]
                    CLmiscDocketDate = DateService.dateString2Date(inDate:splitLine[15])
                    
                    client = SDClient(internalID: CLinternalID, lastName: CLlastName, firstName: CLfirstName, middleName: CLmiddleName, suffix: CLsuffix, addr1: CLaddr1, addr2: CLaddr2, city: CLcity, state: CLstate, zip: CLzip, phone: CLphone, note: CLnote, miscDocketDate: CLmiscDocketDate)
                    client.practice = selected
                    cause.client = client
                    representation = SDRepresentation()
                    
                    addClient(sdCLI: client, sdCAU: cause, line: firstLine)
                    
                    continue
                } // end of splitLine[2] == "SCL"
                if splitLine[2] == "SRE" { // this is a representation for the cause
                    if splitLine.count > 4 {
                        if splitLine[4] == "SAP" {
                            APinternalID = Int(splitLine[5]) ?? -1
                            APappeardate = splitLine[6]
                            APappearTime = splitLine[7]
                            APappearDateTime =  DateService.dateString2Date(inDate: APappeardate, inTime: APappearTime)
                            APappearNote = splitLine[8]
                            APappearReason = splitLine[9]
                            appearance = SDAppearance(internalID: APinternalID, appearDateTime: APappearDateTime, appearNote: APappearNote, appearReason: APappearReason, representation: representation)
                            appearance.practice = selected
                            modelContext.insert(appearance)
                            do {
                                try modelContext.save()
                                CVModel.restoreReport += "inserted appearance: \(firstLine)\n"
                            } catch {
                                let rptLine: String = "error inserting appearance \(firstLine): \(error.localizedDescription)"
                                print(rptLine)
                                CVModel.restoreReport += "\(rptLine)\n"
                            }
                            continue
                        }
                        if splitLine[4] == "SNO" {
                            NOinternalID = Int(splitLine[5]) ?? -1
                            NOnoteNote = splitLine[6]
                            NOnoteDateTime = DateService.dateString2Date(inDate: splitLine[7], inTime: splitLine[8])
                            NOnoteCategory = splitLine[9]
                            note = SDNote(internalID: NOinternalID, noteDateTime: NOnoteDateTime, noteNote: NOnoteNote, noteCategory: NOnoteCategory, representation: representation)
                            note.practice = selected
                            modelContext.insert(note)
                            do {
                                try modelContext.save()
                                CVModel.restoreReport += "inserted note: \(firstLine)\n"
                            } catch {
                                let rptLine: String = "error inserting note \(firstLine): \(error.localizedDescription)"
                                print(rptLine)
                                CVModel.restoreReport += "\(rptLine)\n"
                            }
                            continue
                        }
                    } // end of splitLine.count > 4
                    REinternalID = Int(splitLine[3]) ?? -1
                    REactive = splitLine[4] == "true"
                    REassignedDateTime = DateService.dateString2Date(inDate:splitLine[5])
                    REdispositionDateTime = DateService.dateString2Date(inDate:splitLine[6])
                    REdispositionType = splitLine[7]
                    REdispositionAction = splitLine[8]
                    REprimaryCategory = splitLine[9]
                    representation = SDRepresentation(internalID: REinternalID, active: REactive, assignedDate: REassignedDateTime, dispositionDate: REdispositionDateTime, dispositionType: REdispositionType, dispositionAction: REdispositionAction, primaryCategory: REprimaryCategory)
                    representation.cause = cause
                    representation.client = client
                    modelContext.insert(representation)
                    do {
                        try modelContext.save()
                        CVModel.restoreReport += "inserted representation: \(firstLine)\n"
                    } catch {
                        let rptLine: String = "error inserting representation \(firstLine): \(error.localizedDescription)"
                        print(rptLine)
                        CVModel.restoreReport += "\(rptLine)\n"
                    }
                    continue
                } // end of splitLine[2] == "SRE"
/*
    It's not a client or a representation - must be a cause
*/
                CAinternalID = Int(splitLine[1]) ?? -1
                CAcauseNo = splitLine[2]
                CAcauseType = splitLine[3]
                CAlevel = splitLine[4]
                CAcourt = splitLine[5]
                CAoriginalCharge = splitLine[6]
                cause = SDCause(internalID: CAinternalID, causeNo: CAcauseNo, causeType: CAcauseType, level: CAlevel, court: CAcourt, originalCharge: CAoriginalCharge)
                cause.practice = selected
                cause.client = SDClient()
                cause.representations = []
                modelContext.insert(cause)
                do {
                    try modelContext.save()
                    CVModel.restoreReport += "inserted cause: \(firstLine)\n"
                } catch {
                    let rptLine: String = "error inserting cause \(firstLine): \(error.localizedDescription)"
                    print(rptLine)
                    CVModel.restoreReport += "\(rptLine)\n"
                }
            } // end of splitLine.count > 2
        } // end of workingLines.count > 0
    } // end of handleSingleCause
*/
    
    func checkCauseCLients(sdCLI: SDClient, sdCAU: SDCause, line: String) {
        if sdCLI.causes == nil {
            sdCLI.causes = [sdCAU]
            do {
                try modelContext.save()
                CVModel.restoreReport += "updated cause for client: \(line)\n"
            } catch {
                let rptLine: String = "error updating cause for client \(line): \(error.localizedDescription)"
                print(rptLine)
                CVModel.restoreReport += "\(rptLine)\n"
            }
            return
        } else {
            for cau in sdCLI.causes ?? [] {
                if sdCAU == cau {
                    return
                }
            }
            sdCLI.causes?.append(sdCAU)
            do {
                try modelContext.save()
                CVModel.restoreReport += "updated cause for client: \(line)\n"
            } catch {
                let rptLine: String = "error updating cause for client \(line): \(error.localizedDescription)"
                print(rptLine)
                CVModel.restoreReport += "\(rptLine)\n"
            }
        }
    }
    
    func rcdID(type: String, number: Int) -> String {
        let idNum: String = String(format: "%05d", number)
        let rcdID: String = "\(type)^\(idNum)"
        return rcdID
    }
    
    func splitLineOut(line: String) -> [String] {
        return line.components(separatedBy: "^")
    }
    
    func readFile() -> String {
        var flatString: String = ""
        let backupURL = getDocumentsDirectory().appendingPathComponent("flatbackup.txt")
        do {
            let backupData = try Data(contentsOf: backupURL)
            flatString = String(decoding: backupData, as: UTF8.self)
        } catch {
            print("Error reading file: \(error)")
        }
        return flatString
    }

    func locateClient(reqClient: Int) -> SDClient? {
        if reqClient <= 0 {
            return nil
        }
        for cli in clients {
            if cli.internalID == reqClient {
                return cli
            }
        }
        return nil
    }
    
    func locateCause(reqCause: Int) -> SDCause? {
        if reqCause <= 0 {
            return nil
        }
        for cau in causes {
            if cau.internalID == reqCause {
                return cau
            }
        }
        return nil
    }
    
    func locateRepresentative(reqRep: Int) -> SDRepresentation? {
        if reqRep <= 0 {
            return nil
        }
        for rep in representations {
            if rep.internalID == reqRep {
                return rep
            }
        }
        return nil
    }
    
    func locateAppearance(reqApp: Int) -> SDAppearance? {
        if reqApp <= 0 {
            return nil
        }
        for app in appearances {
            if app.internalID == reqApp {
                return app
            }
        }
        return nil
    }

    func getDocumentsDirectory() -> URL {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let userBackupURL = documentsURL.appendingPathComponent("backups")
        return userBackupURL
    }
    
    func writeRestoreReport(fileContents:String) {
        let outputFileName = getDocumentsDirectory().appendingPathComponent("restorereport.txt")
        do {
            try fileContents.write(to: outputFileName, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            print("Error writing file: \(error)")
        }
    }
}
