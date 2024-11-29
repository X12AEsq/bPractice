//
//  CommonViewModel.swift
//  bLawPractice
//
//  Created by Morris Albers on 11/17/24.
//

import Foundation
import SwiftUI
import SwiftData

class CommonViewModel: ObservableObject {
    @Published var appStatus:String = ""
    
    public var buPackage: JSPackage = JSPackage()
    public var restoreReport: String = ""
    
    var selectedClient: SDClient? = nil
    var selectedCause: SDCause? = nil
    var selectedRepresentation: SDRepresentation? = nil
    var selectedAppearance: SDAppearance? = nil
    var selectedNote: SDNote? = nil
}
