//
//  MagnifierRect.swift
//  
//
//  Created by Samu András on 2020. 03. 04..
//

import SwiftUI

public struct MagnifierRect: View {
    @Binding var currentNumber: Double
    var valueSpecifier: String
    @Environment(\.colorScheme) var colorScheme: ColorScheme

    public var body: some View {
        HStack(alignment: .lastTextBaseline, spacing: 2) { // Use lastTextBaseline for alignment
                   Text("$US")
                       .font(.system(size: 15, weight: .bold)) // Smaller font size for "$US"
                       .baselineOffset(0) // Adjust the baseline offset to align the bottom of the smaller text with the larger text
                       .foregroundColor(.white)
                   
                   Text("\(self.currentNumber, specifier: valueSpecifier)")
                       .font(.system(size: 26, weight: .bold)) // Larger font size for the value
                       .foregroundColor(.white)
               }
        .padding(8)
        .foregroundColor(.white)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(Color(UIColor(red: 45/255, green: 45/255, blue: 45/255, alpha: 1.0)))
                .shadow(color: .black, radius: 7, x: 0, y: 3)
        )
        .offset(x: 0, y: -110)
    }
}
