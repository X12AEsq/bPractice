//
//  NavigationStateManager.swift
//  aPractice
//
//  Created by Morris Albers on 7/14/24.
//

import Foundation
import SwiftUI

class NavigationStateManager: ObservableObject {

    @Published var selectionPath = NavigationPath()
    
    func popToRoot() {
            selectionPath = NavigationPath()
    }
    func goToSettings() {
 //               ...
    }
}
