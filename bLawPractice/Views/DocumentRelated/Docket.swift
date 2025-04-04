//
//  Docket.swift
//  bLawPractice
//
//  Created by Morris Albers on 11/28/24.
//

import SwiftUI
import SwiftData

struct Docket: View {
    @Environment(\.modelContext) var modelContext
    @EnvironmentObject var CVModel:CommonViewModel
    @EnvironmentObject var nav: NavigationStateManager

    @Query(sort: [SortDescriptor(\SDAppearance.appearDateTime)]) var sortedAppearances: [SDAppearance]
    @Query(sort: [SortDescriptor(\SDNote.noteDateTime, order: .reverse)]) var sortedNotes: [SDNote]

    @State var docketLocation:String = ""
    @State var showDocket:Bool = false
    @State var docketDate:Date = Date()
    @State var docketString:String = ""
    @State var docketCompare:String = ""
    @State var docketReady:Bool = false
    @State var docketURL:URL?

    var practice: SDPractice

    var body: some View {
        HStack(alignment:.top) {
            VStack (alignment: .leading  ) {
                Text(moduleTitle())
                    .font(.system(size: 30))
                    .padding(.leading, 20)
                if docketLocation != "" {
                    HStack {
                        Text("Docket location: ")
                        Text(docketLocation)
                    }
                    .padding(.leading, 20)
                }
                if !showDocket {
                    HStack {
                        HStack {
                            Spacer()
                            DatePicker("Docket Date", selection: $docketDate, displayedComponents: [.date])
                                .padding()
                                .onChange(of: docketDate, {
                                    docketString = docketDate.formatted(date: .complete, time: .omitted)
                                    docketCompare = DateService.dateDate2String(inDate: docketDate, short: true)
                                })
                            Spacer()
                        }
                        .frame(minWidth: 75, maxWidth: 300)
                        Button {
                            showDocket = true
                            docketReady = false
                        } label: {
                            Text(" Docket ")
                                .font(.system(size: 30))
                        }
                        .buttonStyle(CustomButtonBlack())
                        Spacer()
                    }
                    .padding(.leading, 20)
                } else {
                    ForEach(candidates(), id: \.self) { appr in
                        HStack {
                            Text("\(appr.internalID)")
                            Text(appr.appearDate)
                            Text(appr.appearTime)
                            Text(appr.representation?.client?.fullName ?? "No Client")
                        }
                        .padding(.leading, 20)
                        .padding(.bottom, 5)
                    }
                    HStack {
                        Button {
                            showDocket = false
                            docketReady = false
                        } label: {
                            Text(" Done ")
                                .font(.system(size: 30))
                        }
                        .buttonStyle(CustomButtonBlack())
                        Button {
                            docketLocation = ""
                            let docket = generatePDF()
                            docketURL = savePDF(data: docket!, fileName: "Docket" + docketCompare)
                            docketLocation = docketURL?.absoluteString ?? ""
                        } label: {
                            Text(" Print ")
                                .font(.system(size: 30))
                        }
                        .buttonStyle(CustomButtonBlack())
                        if docketReady {
                            ShareLink(item: docketURL!)
                        }
                        Spacer()
                    }
                    .padding(.leading, 20)
                }
            }
        }
        .onAppear(perform: {
            showDocket = false
        })
    }
    
    func candidates() -> [SDAppearance] {
        struct apprExtr {
            var sortKey: String
            var appearance: SDAppearance
        }
        var extracts: [apprExtr] = []
        let filteredAppearances:[SDAppearance] = sortedAppearances.filter({ DateService.dateDate2String(inDate: $0.appearDateTime, short: true)
            == docketCompare })
        for appearance in filteredAppearances {
            extracts.append(apprExtr(sortKey: appearance.appearTime + clientName(rep: appearance.representation), appearance: appearance))
        }
        let sortedExtracts = extracts.sorted(by: { $0.sortKey < $1.sortKey })
        var returnedAppearances:[SDAppearance] = []
        for extract in sortedExtracts {
            returnedAppearances.append(extract.appearance)
        }
        return returnedAppearances
    }
    
    func candidateNote(appr: SDAppearance) -> (valid:Bool, latestNote:SDNote?) {
         if let workrep:SDRepresentation = appr.representation {
            if workrep.notes?.count ?? -1 > 0 {
                let worknotes: [SDNote] = workrep.notes?.sorted(by: { $0.noteDateTime > $1.noteDateTime }) ?? []
                return (true, worknotes.first)
            }
        }
        return (false, nil)
    }

    func generatePDF() -> Data? {
    /**
    W: 8.5 inches * 72 DPI = 612 points
    H: 11 inches * 72 DPI = 792 points
    A4 = [W x H] 595 x 842 points
    */

        let pageWidth: CGFloat = 612
        let pageHeight: CGFloat = 792
        let margin: CGFloat = 50
        let contentWidth = pageWidth - 2 * margin
        var pageCount:Int = 0
        var currentY: CGFloat = pageHeight

        let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight))

        let data = pdfRenderer.pdfData { context in
            for appr in candidates() {
                let nextY = currentY + 100
                if nextY > pageHeight {
                    pageCount += 1
                    context.beginPage()
                    
                    if let watermark = UIImage(named: "AlbersMorrisLOGO copy") {
                        addImage(pageRect: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight), image: watermark)
                    }
                    
                    // Draw table headers
                    currentY = drawPageHeader(at: CGPoint(x: margin, y: margin), pageWidth: pageWidth)
                }
                currentY = drawDocketLine(appr:appr, at: CGPoint(x: margin, y: currentY), pageWidth: contentWidth + margin)
            }
        }

        return data
    }

    func addImage(pageRect: CGRect, image:UIImage) {
            let aspectWidth = (pageRect.width - 100) / image.size.width
            let aspectHeight = (pageRect.height - 100) / image.size.height
            let aspectRatio = min(aspectWidth, aspectHeight)
        
            let scaledWidth = image.size.width * aspectRatio
            let scaledHeight = image.size.height * aspectRatio
        
            let imageX = (pageRect.width - scaledWidth) / 2.0
            let imageY = (pageRect.height - scaledHeight) / 2.0
            let imageRect = CGRect(x: imageX, y: imageY, width: scaledWidth, height: scaledHeight)
        
            image.draw(in: imageRect)
    }
    
    func drawPageHeader(at origin: CGPoint, pageWidth: CGFloat) -> CGFloat {
        let headerRowHeight:CGFloat = 25
        let header = practice.name ?? "Unidentified Practice"
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 18),
            .paragraphStyle: paragraphStyle
        ]
        
        let headerRect = CGRect(x: origin.x, y: origin.y, width: pageWidth, height: headerRowHeight)
        let attributedString = NSAttributedString(string: header, attributes: attributes)
        attributedString.draw(in: headerRect)
        
        let header2 = "Docket for " + docketString
        let header2Rect = CGRect(x: origin.x, y: origin.y + headerRowHeight, width: pageWidth, height: headerRowHeight)
        let attributedString2 = NSAttributedString(string: header2, attributes: attributes)
        attributedString2.draw(in: header2Rect)
        
        return origin.y + 60
    }

    func moduleTitle() -> String {
        let prName = practice.name ?? "Unidentified Practice"
        return prName + " Documents"
    }
    
    func savePDF(data: Data, fileName: String) -> URL? {
        let fileManager = FileManager.default
        guard let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        let fileURL = documentDirectory.appendingPathComponent("\(fileName).pdf")
        
        do {
            try data.write(to: fileURL)
            docketReady = true
            return fileURL
        } catch {
            print("Error saving PDF: \(error.localizedDescription)")
            docketReady = false
            return nil
        }
    }
    
    func drawDocketLine(appr: SDAppearance, at origin: CGPoint, pageWidth: CGFloat) -> CGFloat {
        let rowHeight: CGFloat = 14
        let rowStart: CGFloat = origin.y + rowHeight
        let numericStyle = NSMutableParagraphStyle()
        let alphaStyle = NSMutableParagraphStyle()
        numericStyle.alignment = .right
        alphaStyle.alignment = .left
        let interField:CGFloat = 5
        let searchResult = candidateNote(appr: appr)

        let numericAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12),
            .paragraphStyle: numericStyle
        ]
        
        let alphaAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12),
            .paragraphStyle: alphaStyle
        ]
        
        let apprBorder:CGRect = CGRect(x: origin.x, y: origin.y, width: pageWidth, height: 100)
        
        if let image = UIImage(named: "Border") {
            image.draw(in: apprBorder )
        }
        
        let apprIDWidth: CGFloat = 50
        let apprIDRect = CGRect(x: origin.x, y: rowStart, width: apprIDWidth, height: rowHeight)
        let apprIDString = NSAttributedString(string: String(appr.internalID), attributes: numericAttributes)
        apprIDString.draw(in: apprIDRect)
        
        let apprTimeWidth: CGFloat = 40
        let apprTimeStart: CGFloat = origin.x + apprIDWidth + interField
        let apprTimeRect = CGRect(x: apprTimeStart, y: rowStart, width: apprTimeWidth, height: rowHeight)
        let apprTimeString = NSAttributedString(string: appr.appearTime, attributes: alphaAttributes)
        apprTimeString.draw(in: apprTimeRect)
        
        let apprCauseNoWidth: CGFloat = 75
        let apprCauseNoStart: CGFloat = apprTimeStart + apprTimeWidth + interField
        let apprCauseNoRect = CGRect(x: apprCauseNoStart, y: rowStart, width: apprCauseNoWidth, height: rowHeight)
        let apprCauseNoString = NSAttributedString(string: appr.representation?.cause?.causeNo ?? "No Cause No", attributes: alphaAttributes)
        apprCauseNoString.draw(in: apprCauseNoRect)

        let apprCauseDescrWidth: CGFloat = 85
        let apprCauseDescrStart: CGFloat = apprCauseNoStart + apprCauseNoWidth + interField
        let apprCauseDescrRect = CGRect(x: apprCauseDescrStart, y: rowStart, width: apprCauseDescrWidth, height: rowHeight)
        let apprCauseDescrString = NSAttributedString(string: appr.representation?.cause?.originalCharge ?? "No Cause Charge", attributes: alphaAttributes)
        apprCauseDescrString.draw(in: apprCauseDescrRect)

        let apprTypeDescrWidth: CGFloat = 50
        let apprTypeDescrStart: CGFloat = apprCauseDescrStart + apprCauseDescrWidth + interField
        let apprTypeDescrRect = CGRect(x: apprTypeDescrStart, y: rowStart, width: apprTypeDescrWidth, height: rowHeight)
        let apprTypeDescrString = NSAttributedString(string: appr.appearReason, attributes: alphaAttributes)
        apprTypeDescrString.draw(in: apprTypeDescrRect)

        let apprNameWidth: CGFloat = 200
        let apprNameStart: CGFloat = apprTypeDescrStart + apprTypeDescrWidth + interField
        let apprNameRect = CGRect(x: apprNameStart, y: rowStart, width: apprNameWidth, height: rowHeight)
        let apprNameString = NSAttributedString(string: clientName(rep: appr.representation), attributes: alphaAttributes)
        apprNameString.draw(in: apprNameRect)
 
        let row1Start: CGFloat = rowStart + rowHeight
        let apprNoteWidth: CGFloat = 500
        let apprNoteRect = CGRect(x: apprTimeStart, y: row1Start, width: apprNoteWidth, height: rowHeight)
        let apprNoteString = NSAttributedString(string: String(appr.appearNote), attributes: alphaAttributes)
        apprNoteString.draw(in: apprNoteRect)
        
        let row2Start: CGFloat = row1Start + rowHeight

        if searchResult.valid {
            let apprDateWidth: CGFloat = 80
            let apprDateStart: CGFloat = origin.x + apprIDWidth + interField
            let apprDateRect = CGRect(x: apprDateStart, y: row2Start, width: apprDateWidth, height: rowHeight)
            let apprDateString = NSAttributedString(string: searchResult.latestNote?.noteDate.description ?? "----", attributes: alphaAttributes)
            apprDateString.draw(in: apprDateRect)
            
            let apprNoteWidth: CGFloat = 500
            let apprNoteStart: CGFloat = apprDateStart + apprDateWidth + interField
            let apprNoteRect = CGRect(x: apprNoteStart, y: row2Start, width: apprNoteWidth, height: rowHeight)
            let noteText:String = searchResult.latestNote?.noteNote ?? "---- No Note"
            let apprNoteString = NSAttributedString(string: noteText, attributes: alphaAttributes)
            apprNoteString.draw(in: apprNoteRect)


        }
        
        return row2Start + 100
    }

    func clientName(rep:SDRepresentation?) -> String {
        if let rtnRep = rep {
            if let repClient = rtnRep.client {
                return repClient.fullName
            } else {
                if let repCause = rtnRep.cause {
                    if let repCauseClient = repCause.client {
                        rtnRep.client = repCauseClient
                        do {
                            try modelContext.save()
                            CVModel.selectedRepresentation = rtnRep
                        } catch {
                            print( "Error inserting new representation: \(error.localizedDescription)")
                        }
                        return repCauseClient.fullName
                    }
                }
            }
            return "No Client Name"
        } else {
            return "No Representation"
        }
    }
}

//#Preview {
//    Docket()
//}
