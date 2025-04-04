//
//  CustomButtonBlack.swift
//  bLawPractice
//
//  Created by Morris Albers on 11/23/24.
//

import Foundation
import SwiftUI

struct CustomButtonBlack: ButtonStyle {
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.black)
            .background(.white.opacity(0.3), in: RoundedRectangle(cornerRadius: 5, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 5).stroke(.black, lineWidth: 2))
    }
}
