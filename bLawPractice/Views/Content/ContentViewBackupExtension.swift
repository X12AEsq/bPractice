//
//  ContentViewBackupExtension.swift
//  bLawPractice
//
//  Created by Morris Albers on 11/17/24.
//

import Foundation

extension ContentView {
    
    func writeFile(fileContents:String) -> URL {
        let outputFileName = getDocumentsDirectory().appendingPathComponent("flatbackup3.txt")
        do {
            try fileContents.write(to: outputFileName, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            print("Error writing file: \(error)")
        }
        return outputFileName
    }
    
    func createFlatBackup() -> URL {
        var backupString: String = ""
        
        for sdp in self.practices {
            let sdpString = "\(rcdID(type: "SDP", number: sdp.internalId ?? -1))^\(sdp.addr1 ?? "")^\(sdp.addr2 ?? "")^\(sdp.city ?? "")^\(sdp.name ?? "")^\(sdp.shortName ?? "")^\(sdp.state ?? "")^\(sdp.testing ?? false)^\(sdp.zip ?? "")\n"
            backupString += sdpString
            
        }
        
        for scl in sortedClients {
            let sclString = "\(rcdID(type: "SCL", number: scl.internalID ?? -1))^\(scl.lastName ?? "")^\(scl.firstName ?? "")^\(scl.middleName ?? "")^\(scl.suffix ?? "")^\(scl.addr1 ?? "")^\(scl.addr2 ?? "")^\(scl.city ?? "")^\(scl.state ?? "")^\(scl.zip ?? "")^\(scl.phone ?? "")^\(scl.note ?? "")^\(DateService.dateDate2String(inDate:scl.miscDocketDate ?? Date.distantPast, short:true))\n"
            backupString += sclString
        }
        
        for sca in sortedCauses {
            let scaID: String = rcdID(type: "SCA", number: sca.internalID)
            let scaString = "\(scaID)^\(sca.causeNo ?? "")^\(sca.causeType ?? "")^\(sca.level ?? "")^\(sca.court ?? "")^\(sca.originalCharge ?? "")^\(sca.client?.internalID ?? 0)\n"
            backupString += scaString
        }
 
        for sno in sortedNotes {
            let snoID = rcdID(type: "SNO", number: sno.internalID)
            let snoString = "\(snoID)^\(sno.noteNote)^\(DateService.dateDate2String(inDate:sno.noteDateTime, short:true))^\(DateService.dateTime2String(inDate: sno.noteDateTime))^\(sno.noteCategory)^\(sno.representation?.internalID ?? 0)\n"
            backupString += snoString
        }

        for sap in sortedAppearances {
            let sapID: String = rcdID(type: "SAP", number: sap.internalID)
            let sapString = "\(sapID)^\(DateService.dateDate2String(inDate:sap.appearDateTime, short:true))^\(DateService.dateTime2String(inDate:sap.appearDateTime))^\(sap.appearNote)^\(sap.appearReason)^\(sap.representation?.internalID ?? 0)\n"
            backupString += sapString
        }

        for sre in sortedRepresentations {
            let sreID: String = rcdID(type: "SRE", number: sre.internalID)
            let sreString = "\(sreID)^\(sre.active)^\(DateService.dateDate2String(inDate:sre.assignedDateTime, short:true))^\(DateService.dateDate2String(inDate:sre.dispositionDateTime, short:true))^\(sre.dispositionType)^\(sre.dispositionAction)^\(sre.primaryCategory)^\(sre.client?.internalID ?? 0)^\(sre.cause?.internalID ?? 0)\n"
            backupString += sreString
        }

        let returnURL = writeFile(fileContents: backupString)
        return returnURL
    }
}
