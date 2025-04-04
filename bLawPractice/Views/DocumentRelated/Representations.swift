//
//  Representations.swift
//  bLawPractice
//
//  Created by Morris Albers on 2/24/25.
//

import SwiftUI
import SwiftData

struct Representations: View {
    @Environment(\.modelContext) var modelContext
    @EnvironmentObject var CVModel:CommonViewModel
    @EnvironmentObject var nav: NavigationStateManager
    
    @Query(sort: [SortDescriptor(\SDRepresentation.internalID)]) var sortedRepresentations: [SDRepresentation]

    @State var reportLocation:String = ""
    @State var showReport:Bool = false
    @State var reportDate:Date = Date()
    @State var reportString:String = ""
    @State var reportDateString:String = ""
    @State var reportSortOrder: String = ""
    @State var docketReady:Bool = false
    @State var reportURL:URL?
    
    var practice: SDPractice
    
    var body: some View {
        HStack(alignment:.top) {
            VStack (alignment: .leading  ) {
                Text(moduleTitle())
                    .font(.system(size: 30))
                    .padding(.leading, 20)
                if reportLocation != "" {
                    HStack {
                        Text("Report location: ")
                        Text(reportLocation)
                    }
                    .padding(.leading, 20)
                }
                if !showReport {
                    HStack {
                        HStack {
                            Text("Sort Order")
                            Picker("", selection: $reportSortOrder) {
                                ForEach(RepresentationSorts.representationSorts, id: \.self) {
                                    Text($0)
                                }
                            }
                            Text(RepresentationSorts.xlateType(inType: reportSortOrder).descr)
                        }

//                        HStack {
//                            Spacer()
//                            DatePicker("Docket Date", selection: $reportDate, displayedComponents: [.date])
//                                .padding()
//                                .onChange(of: reportDate, {
//                                    reportString = reportDate.formatted(date: .complete, time: .omitted)
//                                    reportDateString = DateService.dateDate2String(inDate: reportDate, short: true)
//                                })
//                            Spacer()
//                        }
//                        .frame(minWidth: 75, maxWidth: 300)
                        Button {
                            showReport = true
                            docketReady = false
                        } label: {
                            Text(" Report ")
                                .font(.system(size: 30))
                        }
                        .buttonStyle(CustomButtonBlack())
                        Spacer()
                    }
                    .padding(.leading, 20)
                } else {
                    HStack {
                        Button {
                            showReport = false
                            docketReady = false
                        } label: {
                            Text(" Done ")
                                .font(.system(size: 30))
                        }
                        .buttonStyle(CustomButtonBlack())
                        Button {
                            reportLocation = ""
                            let report = generatePDF()
                            reportURL = savePDF(data: report!, fileName: "Representations" + reportDateString)
                            reportLocation = reportURL?.absoluteString ?? ""
                        } label: {
                            Text(" Print ")
                                .font(.system(size: 30))
                        }
                        .buttonStyle(CustomButtonBlack())
                        if docketReady {
                            ShareLink(item: reportURL!)
                        }
                        Spacer()
                    }
                    ScrollView {
                        ForEach(candidates(), id: \.self) { rep in
                            HStack {
                                Text("\(rep.internalID)")
                                //                            Text(rep.appearDate)
                                //                            Text(rep.appearTime)
                                Text(rep.client?.fullName ?? "No Client")
                            }
                            .padding(.leading, 20)
                            .padding(.bottom, 5)
                        }
                    }
                    .padding(.leading, 20)
                }
            }
        }
        .onAppear(perform: {
            showReport = false
            reportDateString = DateService.dateDate2String(inDate: reportDate, short: true)
        })
    }
    
    func moduleTitle() -> String {
        let prName = practice.name ?? "Unidentified Practice"
        return prName + " Documents"
    }

    func candidates() -> [SDRepresentation] {
        switch reportSortOrder {
        case "Assigned Date":
            return sortedRepresentations.sorted(by: { $0.assignedDate > $1.assignedDate })
        case "Closed Date":
            return sortedRepresentations.sorted(by: { $0.dispositionDate > $1.dispositionDate })
        case "Active":
            let workReps1:[SDRepresentation] = sortedRepresentations.filter({$0.active}).sorted(by: {$0.client?.fullName ?? "" < $1.client?.fullName ?? ""})
            let workReps2:[SDRepresentation] = sortedRepresentations.filter({!$0.active}).sorted(by: {$0.client?.fullName ?? "" < $1.client?.fullName ?? ""})
            return workReps1 + workReps2
        case "Client Name":
            return sortedRepresentations.sorted(by: {$0.client?.fullName ?? "" < $1.client?.fullName ?? ""})
        case "Assigned Only":
            return sortedRepresentations.filter({$0.active && $0.cause?.causeType != "Priv" && $0.cause?.level != "CPS"}).sorted(by: {$0.client?.fullName ?? "" < $1.client?.fullName ?? ""})                                                
        default:
            return []
        }
     }
    
    func generatePDF() -> Data? {
        let pageWidth: CGFloat = 612
        let pageHeight: CGFloat = 792
        let margin: CGFloat = 50
        let contentWidth = pageWidth - 2 * margin
        let pageLimit: CGFloat = pageHeight + 50
        var pageCount:Int = 0
        var currentY: CGFloat = pageHeight

        let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight))

        let data = pdfRenderer.pdfData { context in
            for rep in candidates() {
                let nextY = currentY + 100
                if nextY > pageLimit {
                    pageCount += 1
                    context.beginPage()
                    
                    if let watermark = UIImage(named: "AlbersMorrisLOGO copy") {
                        addImage(pageRect: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight), image: watermark)
                    }
                    
                    // Draw table headers
                    currentY = drawPageHeader(at: CGPoint(x: margin, y: margin), pageWidth: pageWidth)
                }
                currentY = drawReportLine(rep: rep, at: CGPoint(x: margin, y: currentY), pageWidth: contentWidth + margin) - 4
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
        let alphaStyle = NSMutableParagraphStyle()
        let numericStyle = NSMutableParagraphStyle()
        let interField:CGFloat = 4
        numericStyle.alignment = .right
        alphaStyle.alignment = .left
        let rowHeight: CGFloat = 12
//        let rowStart: CGFloat = origin.y + rowHeight
        paragraphStyle.alignment = .left
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 18),
            .paragraphStyle: paragraphStyle
        ]
        
        let alphaAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10),
            .paragraphStyle: alphaStyle
        ]

        let numericAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10),
            .paragraphStyle: numericStyle
        ]

        let headerRect = CGRect(x: origin.x, y: origin.y, width: pageWidth, height: headerRowHeight)
        let attributedString = NSAttributedString(string: header, attributes: attributes)
        attributedString.draw(in: headerRect)
        
        let header2 = "Representations as of " + reportDateString
        let header2Rect = CGRect(x: origin.x, y: origin.y + headerRowHeight, width: pageWidth, height: headerRowHeight)
        let attributedString2 = NSAttributedString(string: header2, attributes: attributes)
        attributedString2.draw(in: header2Rect)

        let header3Y: CGFloat = origin.y + (headerRowHeight * 2.0)
        let repIDWidth: CGFloat = 30
        let repIDStart = origin.x
        let repIDRect = CGRect(x: repIDStart, y: header3Y, width: repIDWidth, height: rowHeight)
        let repIDString = NSAttributedString(string: "ID", attributes: numericAttributes)
        repIDString.draw(in: repIDRect)
        
        let repNameWidth: CGFloat = 130
        let repNameStart: CGFloat = repIDStart + repIDWidth + interField
        let repNameRect = CGRect(x: repNameStart, y: header3Y, width: repNameWidth, height: rowHeight)
        let repNameString = NSAttributedString(string: "Client", attributes: alphaAttributes)
        repNameString.draw(in: repNameRect)
        
        let repActiveWidth: CGFloat = 40
        let repActiveStart: CGFloat = repNameStart + repNameWidth + interField
        let repActiveRect = CGRect(x: repActiveStart, y: header3Y, width: repActiveWidth, height: rowHeight)
        let repActiveString = NSAttributedString(string: "Status", attributes: alphaAttributes)
        repActiveString.draw(in: repActiveRect)
        
        let repAssignedWidth: CGFloat = 60
        let repAssignedStart: CGFloat = repActiveStart + repActiveWidth + interField
        let repAssignedRect = CGRect(x: repAssignedStart, y: header3Y, width: repAssignedWidth, height: rowHeight)
        let repAssignedString = NSAttributedString(string: "Assigned", attributes: alphaAttributes)
        repAssignedString.draw(in: repAssignedRect)

        let repDisposedWidth: CGFloat = 60
        let repDisposedStart: CGFloat = repAssignedStart + repAssignedWidth + interField
        let repDisposedRect = CGRect(x: repDisposedStart, y: header3Y, width: repDisposedWidth, height: rowHeight)
        let repDisposedString = NSAttributedString(string: "Disposed", attributes: alphaAttributes)
        repDisposedString.draw(in: repDisposedRect)
        
        let repCauseNoWidth: CGFloat = 50
        let repCauseNoStart: CGFloat = repDisposedStart + repDisposedWidth + interField
        let repCauseNoRect = CGRect(x: repCauseNoStart, y: header3Y, width: repCauseNoWidth, height: rowHeight)
        let repCauseNoString = NSAttributedString(string: "Cause", attributes: alphaAttributes)
        repCauseNoString.draw(in: repCauseNoRect)
        
        let repCauseTypeWidth: CGFloat = 22
        let repCauseTypeStart: CGFloat = repCauseNoStart + repCauseNoWidth + interField
        let repCauseTypeRect = CGRect(x: repCauseTypeStart, y: header3Y, width: repCauseTypeWidth, height: rowHeight)
        let repCauseTypeString = NSAttributedString(string: "Type", attributes: alphaAttributes)
        repCauseTypeString.draw(in: repCauseTypeRect)
        
        let repCauseLevelWidth: CGFloat = 20
        let repCauseLevelStart: CGFloat = repCauseTypeStart + repCauseTypeWidth + interField
        let repCauseLevelRect = CGRect(x: repCauseLevelStart, y: header3Y, width: repCauseLevelWidth, height: rowHeight)
        let repCauseLevelString = NSAttributedString(string: "Lev", attributes: alphaAttributes)
        repCauseLevelString.draw(in: repCauseLevelRect)
        
        let repCauseActionWidth: CGFloat = 20
        let repCauseActionStart: CGFloat = repCauseLevelStart + repCauseLevelWidth + interField
        let repCauseActionRect = CGRect(x: repCauseActionStart, y: header3Y, width: repCauseActionWidth, height: rowHeight)
        let repCauseActionString = NSAttributedString(string: "Act", attributes: alphaAttributes)
        repCauseActionString.draw(in: repCauseActionRect)
        
        let repRepTypeWidth: CGFloat = 20
        let repRepTypeStart: CGFloat = repCauseActionStart + repCauseActionWidth + interField
        let repRepTypeRect = CGRect(x: repRepTypeStart, y: header3Y, width: repRepTypeWidth, height: rowHeight)
        let repRepTypeString = NSAttributedString(string: "Type", attributes: alphaAttributes)
         repRepTypeString.draw(in: repRepTypeRect)

        return origin.y + 60
    }
    
    func drawReportLine(rep: SDRepresentation, at origin: CGPoint, pageWidth: CGFloat) -> CGFloat {
        let rowHeight: CGFloat = 9
        let rowStart: CGFloat = origin.y + rowHeight
        let numericStyle = NSMutableParagraphStyle()
        let alphaStyle = NSMutableParagraphStyle()
        numericStyle.alignment = .right
        alphaStyle.alignment = .left
        let interField:CGFloat = 4
//        let searchResult = candidateNote(rep: rep)

        let numericAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 8),
            .paragraphStyle: numericStyle
        ]
        
        let alphaAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 8),
            .paragraphStyle: alphaStyle
        ]
        
//        let repBorder:CGRect = CGRect(x: origin.x, y: origin.y, width: pageWidth, height: 100)
//        
//        if let image = UIImage(named: "Border") {
//            image.draw(in: repBorder )
//        }
        
        let repIDWidth: CGFloat = 30
        let repIDStart = origin.x
        let repIDRect = CGRect(x: repIDStart, y: rowStart, width: repIDWidth, height: rowHeight)
        let repIDString = NSAttributedString(string: String(rep.internalID), attributes: numericAttributes)
        repIDString.draw(in: repIDRect)
        
        let repNameWidth: CGFloat = 130
        let repNameStart: CGFloat = repIDStart + repIDWidth + interField
        let repNameRect = CGRect(x: repNameStart, y: rowStart, width: repNameWidth, height: rowHeight)
        let repNameString = NSAttributedString(string: clientName(rep: rep), attributes: alphaAttributes)
        repNameString.draw(in: repNameRect)
        
        let repActiveWidth: CGFloat = 40
        let repActiveStart: CGFloat = repNameStart + repNameWidth + interField
        let repActiveRect = CGRect(x: repActiveStart, y: rowStart, width: repActiveWidth, height: rowHeight)
        let repActiveString = NSAttributedString(string: rep.repActiveString, attributes: alphaAttributes)
        repActiveString.draw(in: repActiveRect)
        
        let repAssignedWidth: CGFloat = 60
        let repAssignedStart: CGFloat = repActiveStart + repActiveWidth + interField
        let repAssignedRect = CGRect(x: repAssignedStart, y: rowStart, width: repAssignedWidth, height: rowHeight)
        let repAssignedString = NSAttributedString(string: rep.assignedDate, attributes: alphaAttributes)
        repAssignedString.draw(in: repAssignedRect)

        let repDisposedWidth: CGFloat = 60
        let repDisposedStart: CGFloat = repAssignedStart + repAssignedWidth + interField
        let repDisposedRect = CGRect(x: repDisposedStart, y: rowStart, width: repDisposedWidth, height: rowHeight)
        let repDisposedString = !rep.active ? NSAttributedString(string: rep.dispositionDate, attributes: alphaAttributes) : NSAttributedString(string: "", attributes: alphaAttributes)
        repDisposedString.draw(in: repDisposedRect)

        let repCauseNoWidth: CGFloat = 50
        let repCauseNoStart: CGFloat = repDisposedStart + repDisposedWidth + interField
        let repCauseNoRect = CGRect(x: repCauseNoStart, y: rowStart, width: repCauseNoWidth, height: rowHeight)
        let repCauseNoString = NSAttributedString(string: rep.causeNo, attributes: alphaAttributes)
        repCauseNoString.draw(in: repCauseNoRect)
        
        let repCauseTypeWidth: CGFloat = 22
        let repCauseTypeStart: CGFloat = repCauseNoStart + repCauseNoWidth + interField
        let repCauseTypeRect = CGRect(x: repCauseTypeStart, y: rowStart, width: repCauseTypeWidth, height: rowHeight)
        let repCauseTypeString = NSAttributedString(string: rep.cause?.causeType ?? "Unknown", attributes: alphaAttributes)
        repCauseTypeString.draw(in: repCauseTypeRect)
        
        let repCauseLevelWidth: CGFloat = 20
        let repCauseLevelStart: CGFloat = repCauseTypeStart + repCauseTypeWidth + interField
        let repCauseLevelRect = CGRect(x: repCauseLevelStart, y: rowStart, width: repCauseLevelWidth, height: rowHeight)
        let repCauseLevelString = NSAttributedString(string: rep.cause?.level ?? "Unk", attributes: alphaAttributes)
        repCauseLevelString.draw(in: repCauseLevelRect)
        
        let repCauseActionWidth: CGFloat = 20
        let repCauseActionStart: CGFloat = repCauseLevelStart + repCauseLevelWidth + interField
        let repCauseActionRect = CGRect(x: repCauseActionStart, y: rowStart, width: repCauseActionWidth, height: rowHeight)
        let repCauseActionString = !rep.active ? NSAttributedString(string: rep.dispositionAction, attributes: alphaAttributes) : NSAttributedString(string: "", attributes: alphaAttributes)
        repCauseActionString.draw(in: repCauseActionRect)
        
        let repRepTypeWidth: CGFloat = 20
        let repRepTypeStart: CGFloat = repCauseActionStart + repCauseActionWidth + interField
        let repRepTypeRect = CGRect(x: repRepTypeStart, y: rowStart, width: repRepTypeWidth, height: rowHeight)
        let repRepTypeString = !rep.active ? NSAttributedString(string: rep.dispositionType, attributes: alphaAttributes) : NSAttributedString(string: "", attributes: alphaAttributes)
         repRepTypeString.draw(in: repRepTypeRect)
        
        let repCategoryWidth: CGFloat = 40
        let repCategoryStart: CGFloat = repRepTypeStart + repRepTypeWidth + interField
        let repCategoryRect = CGRect(x: repCategoryStart, y: rowStart, width: repCategoryWidth, height: rowHeight)
        let repCategoryString = NSAttributedString(string: rep.primaryCategory, attributes: alphaAttributes)
        repCategoryString.draw(in: repCategoryRect)

        return rowStart + rowHeight - 2
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
