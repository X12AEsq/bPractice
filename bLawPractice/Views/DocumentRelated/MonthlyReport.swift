//
//  MonthlyReport.swift
//  bLawPractice
//
//  Created by Morris Albers on 11/29/24.
//

import SwiftUI
import SwiftData

struct MonthlyReport: View {

    @Environment(\.modelContext) var modelContext
    @EnvironmentObject var CVModel:CommonViewModel
    @EnvironmentObject var nav: NavigationStateManager

    @Query(sort: [SortDescriptor(\SDAppearance.appearDateTime)]) var sortedAppearances: [SDAppearance]
    @Query(sort: [SortDescriptor(\SDRepresentation.internalID)]) var sortedRepresentations: [SDRepresentation]
 
    @State var reportLocation:String = ""
    @State var showReport:Bool = false
    @State var reportDate:Date = Date()
    @State var reportString:String = ""
    @State var reportCompare:String = ""
    @State var reportReady:Bool = false
    @State var reportURL:URL?

    let fieldLengths = [
        "Cause No":8,
        "Client Name":35,
        "Lev":5,
        "Court":5,
        "Proc":6,
        "Disp":6]

    var practice: SDPractice

    var body: some View {
        HStack(alignment:.top) {
            VStack (alignment: .leading  ) {
                Text(moduleTitle())
                    .font(.system(size: 30))
                    .padding(.leading, 20)
                if reportLocation != "" {
                    HStack {
                        Text("report location: ")
                        Text(reportLocation)
                    }
                    .padding(.leading, 20)
                }
                if !showReport {
                    HStack {
                        HStack {
                            Spacer()
                            DatePicker("Report Date", selection: $reportDate, displayedComponents: [.date])
                                .padding()
                                .onChange(of: reportDate, {
                                    reportString = reportDate.formatted(date: .complete, time: .omitted)
                                    reportCompare = DateService.dateDate2String(inDate: reportDate, short: true)
                                })
                            Spacer()
                        }
                        .frame(minWidth: 75, maxWidth: 300)
                        Button {
                            showReport = true
                            reportReady = false
                        } label: {
                            Text(" Report ")
                                .font(.system(size: 30))
                        }
                        .buttonStyle(CustomButton1())
                        Spacer()
                    }
                    .padding(.leading, 20)
                } else {
                    VStack (alignment: .leading) {
                        Text("FAYETTE COUNTY")
                            .font(.system(size: 16))
                        Text("CONTRACT ATTORNEY MONTHLY FEE VOUCHER")
                            .font(.system(size: 16))
                        HStack {
                            Text("Month of: \(DateService.monthName(date:reportDate)), \(DateService.todayYear(date:reportDate))")
                            Text("Attorney Name (print): Morris E. Albers II")
                        }
                        HStack {
                            Text("Appointments received during month: \(assignedThisMonth().count)")
                            Text("Number of cases pending end of month: \(openRepresentations().count)")
                        }
                        HStack {
                            Text("Cause No")
                            Text("Client Name")
                            Text("Lev")
                            Text("Court")
                            Text("Proc")
                            Text("Disp")
                        }
                        ForEach(closedThisMonth(), id: \.self) { ctmr in
                            HStack {
                                Text(ctmr.cause?.causeNo ?? "No Num")
                                Text(ctmr.cause?.client?.fullName ?? "No Name")
                                Text(ctmr.cause?.level ?? "None")
                                Text(ctmr.cause?.court ?? "None")
                                Text(ctmr.dispositionType)
                                Text(ctmr.dispositionAction)
                            }
                        }
                    }
                    HStack {
                        Button {
                            showReport = false
                            reportReady = false
                        } label: {
                            Text(" Done ")
                                .font(.system(size: 30))
                        }
                        .buttonStyle(CustomButton1())
                        Button {
                            reportLocation = ""
                            let report = generateReport()
                            reportURL = writeReport(fileContents: report)
                            reportLocation = reportURL?.absoluteString ?? ""
                            reportReady = true
                        } label: {
                            Text(" Print ")
                                .font(.system(size: 30))
                        }
                        .buttonStyle(CustomButton1())
                        if reportReady {
                            ShareLink(item: reportURL!)
                        }
                        Spacer()
                    }
                    .padding(.leading, 20)
                }
            }
            .padding(.leading, 20)

        }
        .onAppear(perform: {
            showReport = false
        })
        Spacer()
    }
    
    func moduleTitle() -> String {
        let prName = practice.name ?? "Unidentified Practice"
        return prName + " Monthly Report"
    }

    func openRepresentations() -> [SDRepresentation] {
        var ors:[SDRepresentation] = [SDRepresentation]()
        for rep in sortedRepresentations {
            if !rep.active { continue }
            if rep.cause?.causeType == "Priv" { continue }
            if rep.cause?.level == "GS" { continue }
            if rep.cause?.level == "CPS" { continue }
            ors.append(rep)
        }
        return ors
    }

    func assignedThisMonth() -> [SDRepresentation] {
        let atm:[SDRepresentation] = sortedRepresentations.filter( { $0.assignedDateTime >= DateService.monthStart(target: reportDate) && $0.assignedDateTime <= DateService.monthEnd(target: reportDate) && $0.cause?.causeType == "Appt"} )
        return atm
    }
    
    func closedThisMonth() -> [SDRepresentation] {
        let ctm:[SDRepresentation] = sortedRepresentations.filter( { !$0.active && $0.dispositionDateTime >= DateService.monthStart(target: reportDate) && $0.dispositionDateTime <= DateService.monthEnd(target: reportDate) && $0.cause?.level != "CPS"} )
        return ctm
    }

    func generateReport() -> String {
        let lineLimit:Int = 60
        var lineCount:Int = 90
        var pageCount:Int = 0
        var workReport: String = ""
        workReport += "FAYETTE COUNTY\n"
        workReport += "Month of: \(DateService.monthName(date:reportDate))), \(DateService.todayYear(date:reportDate))\n"
        workReport += "Attorney Name (print): Morris E. Albers II\n"

        workReport += "Appointments received during month: \(assignedThisMonth().count)\n"
        workReport += "Number of cases pending end of month: \(openRepresentations().count)\n\n"
        
        for ctm in closedThisMonth() {
            if lineCount > lineLimit {
                workReport += generateHeader()
                lineCount = 2
                
            }
            workReport += FormattingService.spaces(len: 5)
            workReport += FormattingService.ljf(base: ctm.cause?.causeNo ?? "No Cause", len: fieldLengths["Cause No"] ?? 10)
            workReport += " "
            workReport += FormattingService.ljf(base: ctm.cause?.client?.fullName ?? "No Name", len: fieldLengths["Client Name"] ?? 10)
            workReport += " "
            workReport += FormattingService.ljf(base: ctm.cause?.level ?? "No Name", len: fieldLengths["Lev"] ?? 10)
            workReport += " "
            workReport += FormattingService.ljf(base: ctm.cause?.court ?? "xxxxx", len: fieldLengths["Court"] ?? 10)
            workReport += " "
            workReport += FormattingService.ljf(base: ctm.dispositionType, len: fieldLengths["Proc"] ?? 10)
            workReport += " "
            workReport += FormattingService.ljf(base: ctm.dispositionAction, len: fieldLengths["Disp"] ?? 10)
            workReport += "\n"
            lineCount += 1
        }
        
        return workReport
    }
    
    func generateHeader() -> String {
        var work:String = FormattingService.spaces(len: 5)
        work += FormattingService.ljf(base: "Cause No", len: fieldLengths["Cause No"] ?? 10)
        work += " "
        work += FormattingService.ljf(base: "Client Name", len: fieldLengths["Client Name"] ?? 10)
        work += " "
        work += FormattingService.ljf(base: "Level", len: fieldLengths["Lev"] ?? 10)
        work += " "
        work += FormattingService.ljf(base: "Court", len: fieldLengths["Court"] ?? 10)
        work += " "
        work += FormattingService.ljf(base: "Proc", len: fieldLengths["Proc"] ?? 10)
        work += " "
        work += FormattingService.ljf(base: "Disp", len: fieldLengths["Disp"] ?? 10)
        work += "\n\n"
        return work
    }
    
    func writeReport(fileContents:String) -> URL {
         let outputFileName = getDocumentsDirectory().appendingPathComponent("MonthlyReport\(DateService.todayYear(date:reportDate))\(DateService.monthName(date:reportDate)).txt")
        do {
            try fileContents.write(to: outputFileName, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            print("Error writing file: \(error)")
        }
        return outputFileName
    }
    
    func getDocumentsDirectory() -> URL {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let userBackupURL = documentsURL.appendingPathComponent("backups")
        return userBackupURL
    }
}

//#Preview {
//    MonthlyReport()
//}
