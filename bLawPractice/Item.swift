//
//  Item.swift
//  bLawPractice
//
//  Created by Morris Albers on 11/17/24.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
