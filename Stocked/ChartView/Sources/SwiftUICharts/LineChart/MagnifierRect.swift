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
    
    var firstValue: Double?

    public init(currentNumber: Binding<Double>, valueSpecifier: String) {
        self._currentNumber = currentNumber
        self.valueSpecifier = valueSpecifier
        // Fetch the first data point from the singleton
        self.firstValue = FirstDataPointSingleton.shared.firstDataPoint
    }

    public var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 2) { // Align based on baseline
            Text("$US")
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.white)
            
            VStack(alignment: .center, spacing: 0) {
                Text("\(self.currentNumber, specifier: valueSpecifier)")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.white)
                
                if let firstValue = firstValue {
                    let percentageDifference = (self.currentNumber - firstValue) / firstValue * 100
                    
                    HStack(spacing: 2) {
                        Image(systemName: percentageDifference > 0 ? "arrow.up" : (percentageDifference < 0 ? "arrow.down" : ""))
                            .font(.system(size: 12))
                            .foregroundColor(percentageDifference > 0 ? Color(UIColor(red: 103/255.0, green: 205/255.0, blue: 103/255.0, alpha: 1.0)) :
                                                (percentageDifference < 0 ? Color(UIColor(red: 234/255.0, green: 85/255.0, blue: 69/255.0, alpha: 1.0)) : .white))
                        
                        Text("(\(percentageDifference, specifier: "%.2f")%)")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(percentageDifference > 0 ? Color(UIColor(red: 103/255.0, green: 205/255.0, blue: 103/255.0, alpha: 1.0)) :
                                                (percentageDifference < 0 ? Color(UIColor(red: 234/255.0, green: 85/255.0, blue: 69/255.0, alpha: 1.0)) : .white))
                    }
                    .frame(width: nil, alignment: .center) // Only center the content without expanding the frame
                }
            }
            Text("$US")
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.clear)
        }

           .padding(8)
           .background(
               RoundedRectangle(cornerRadius: 25)
                   .fill(Color(UIColor(red: 45/255, green: 45/255, blue: 45/255, alpha: 1.0)))
                   .shadow(color: .black, radius: 7, x: 0, y: 3)
           )
           .offset(x: 0, y: -110)
       }
   }

