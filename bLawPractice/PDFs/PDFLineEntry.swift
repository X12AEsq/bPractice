//
//  PDFLineEntry.swift
//  bLawPractice
//
//  Created by Morris Albers on 2/26/25.
//

import SwiftUI
import Foundation

struct PDFLineEntry: Identifiable {
    var id: UUID = UUID()
    var PLEWidth: CGFloat = 0
    var PLEStartX: CGFloat = 0
    var PLEStartY: CGFloat = 0
    var PLERect = CGRect()
    var PLEString = NSAttributedString()
    
    init(id: UUID, PLEWidth: CGFloat, PLEStartX: CGFloat, PLEStartY: CGFloat, PLERect: CGRect = CGRect(), PLEString: NSAttributedString = NSAttributedString()) {
        self.id = id
        self.PLEWidth = PLEWidth
        self.PLEStartX = PLEStartX
        self.PLEStartY = PLEStartY
        self.PLERect = PLERect
        self.PLEString = PLEString
    }

    init(
        PLEWidth: CGFloat, PLEStartX: CGFloat, PLEStartY: CGFloat, PLERect: CGRect = CGRect(), PLEString: NSAttributedString = NSAttributedString()) {
        self.id = UUID()
        self.PLEWidth = PLEWidth
        self.PLEStartX = PLEStartX
        self.PLEStartY = PLEStartY
        self.PLERect = PLERect
        self.PLEString = PLEString
    }

}
