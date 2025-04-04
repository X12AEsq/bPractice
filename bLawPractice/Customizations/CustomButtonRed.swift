//
//  CustomButtonRed.swift
//  bLawPractice
//
//  Created by Morris Albers on 4/2/25.
//


import Foundation
import SwiftUI

struct CustomButtonRed: ButtonStyle {
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.black)
            .background(.red.opacity(0.3), in: RoundedRectangle(cornerRadius: 5, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 5).stroke(.black, lineWidth: 2))
    }
}
