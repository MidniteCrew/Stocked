//
//  LineView.swift
//  LineChart
//
//  Created by András Samu on 2019. 09. 02..
//  Copyright © 2019. András Samu. All rights reserved.
//

import SwiftUI

class FirstDataPointSingleton {
    static let shared = FirstDataPointSingleton()
    
    var firstDataPoint: Double?

    private init() {} // Private initializer to ensure singleton instance
    
    func initialize(with data: [Double]) {
        self.firstDataPoint = data.first
    }
}


public struct LineView: View {
    @ObservedObject var data: ChartData
    public var title: String?
    public var legend: String?
    public var style: ChartStyle
    public var darkModeStyle: ChartStyle
    public var valueSpecifier: String
    public var legendSpecifier: String
    
    @State private var previousDataNumber: Double? // Track the previous data point

    
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @State private var showLegend = false
    @State private var dragLocation:CGPoint = .zero
    @State private var indicatorLocation:CGPoint = .zero
    @State private var closestPoint: CGPoint = .zero
    @State private var opacity:Double = 0
    @State private var currentDataNumber: Double = 0
    @State private var hideHorizontalLines: Bool = false
    
    public init(data: [Double],
                title: String? = nil,
                legend: String? = nil,
                style: ChartStyle = Styles.lineChartStyleOne,
                valueSpecifier: String? = "%.1f",
                legendSpecifier: String? = "%.2f") {
        
        self.data = ChartData(points: data)
        self.title = title
        self.legend = legend
        self.style = style
        self.valueSpecifier = valueSpecifier!
        self.legendSpecifier = legendSpecifier!
        self.darkModeStyle = style.darkModeStyle != nil ? style.darkModeStyle! : Styles.lineViewDarkMode
        // Initialize the FirstDataPointSingleton with the first data point
        FirstDataPointSingleton.shared.initialize(with: data)
    }
    
    // Function to estimate the width of the label for the minimum Y-axis value
       private func minLabelWidth() -> CGFloat {
           let minValue = self.data.onlyPoints().min() ?? 0
           let label = String(format: valueSpecifier, minValue)
           // Estimate the width of the label, adjust the multiplier as needed for your font and size
           return CGFloat(label.count) * 8.0
       }


    
    public var body: some View {
        GeometryReader{ geometry in
            VStack(alignment: .leading, spacing: 8) {
                Group{
                    if (self.title != nil){
                        Text(self.title!)
                            .font(.title)
                            .bold().foregroundColor(self.colorScheme == .dark ? self.darkModeStyle.textColor : self.style.textColor)
                    }
                    if (self.legend != nil){
                        Text(self.legend!)
                            .font(.callout)
                            .foregroundColor(self.colorScheme == .dark ? self.darkModeStyle.legendTextColor : self.style.legendTextColor)
                    }
                }.offset(x: 0, y: 20)
                ZStack{
                    GeometryReader{ reader in
                        Rectangle()
                            .foregroundColor(self.colorScheme == .dark ? self.darkModeStyle.backgroundColor : self.style.backgroundColor)
                        if(self.showLegend){
                            Legend(data: self.data,
                                   frame: .constant(reader.frame(in: .local)), hideHorizontalLines: self.$hideHorizontalLines, specifier: legendSpecifier)
                                .transition(.opacity)
                                .animation(Animation.easeOut(duration: 1).delay(1))
                        }
                        // Use minLabelWidth() to dynamically adjust xOffset
                                               let xOffset = self.minLabelWidth() + 10 // Add some padding for separation

                                               let points = self.data.onlyPoints()
                                               let stepWidth = (geometry.size.width - xOffset) / CGFloat(max(points.count - 1, 1))

                                               Line(data: self.data,
                                                    frame: .constant(CGRect(x: 0, y: 0, width: reader.frame(in: .local).width - xOffset, height: reader.frame(in: .local).height + 25)),
                                                    touchLocation: self.$indicatorLocation,
                                                    showIndicator: self.$hideHorizontalLines,
                                                    minDataValue: .constant(nil),
                                                    maxDataValue: .constant(nil),
                                                    showBackground: false,
                                                    gradient: self.style.gradientColor
                                               )
                                               .offset(x: xOffset, y: 0) // Adjust the line's position based on the calculated xOffset
                        .onAppear(){
                            self.showLegend = true
                        }
                        .onDisappear(){
                            self.showLegend = false
                        }
                    }
                    .frame(width: geometry.frame(in: .local).size.width, height: 240)
                    .offset(x: 0, y: 40 )
                    // Fixed positioned MagnifierRect at the top center
                          MagnifierRect(currentNumber: self.$currentDataNumber, valueSpecifier: self.valueSpecifier)
                              .opacity(self.opacity)
                              .offset(x: 0, y: -10) // Position it towards the top of the graph. Adjust 'y' as needed.
                      }
                      .frame(width: geometry.frame(in: .local).size.width, height: 240)
                      .gesture(DragGesture()
                        .onChanged({ value in
                                
                                let currentClosestPoint = self.getClosestDataPoint(toPoint: value.location, width: geometry.frame(in: .local).size.width - 30, height: 240)
                                if self.currentDataNumber != self.previousDataNumber { // Check if the value has changed
                               
                                    // Trigger haptic feedback only if the value has changed
                                    let impactMed = UIImpactFeedbackGenerator(style: .light)
                                    impactMed.impactOccurred()
                                    self.previousDataNumber = self.currentDataNumber // Update the previous data point
                            }
                              // Update the indicator location for the current value but don't change the magnifier's position
                              self.indicatorLocation = CGPoint(x: max(value.location.x - 30, 0), y: 32)
                              self.opacity = 1
                              self.closestPoint = self.getClosestDataPoint(toPoint: value.location, width: geometry.frame(in: .local).size.width - 30, height: 240)
                              self.hideHorizontalLines = true
                          })
                          .onEnded({ value in
                              self.opacity = 0
                              self.hideHorizontalLines = false
                              self.previousDataNumber = nil // Reset the previous data point
                          })
                )
            }
        }
    }
    
    func getClosestDataPoint(toPoint: CGPoint, width:CGFloat, height: CGFloat) -> CGPoint {
        let points = self.data.onlyPoints()
        let stepWidth: CGFloat = width / CGFloat(points.count-1)
        let stepHeight: CGFloat = height / CGFloat(points.max()! + points.min()!)
        
        let index:Int = Int(floor((toPoint.x-15)/stepWidth))
        if (index >= 0 && index < points.count){
            self.currentDataNumber = points[index]
            return CGPoint(x: CGFloat(index)*stepWidth, y: CGFloat(points[index])*stepHeight)
        }
        return .zero
    }
}

struct LineView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LineView(data: [8,23,54,32,12,37,7,23,43], title: "Full chart", style: Styles.lineChartStyleOne)
            
            LineView(data: [282.502, 284.495, 283.51, 285.019, 285.197, 286.118, 288.737, 288.455, 289.391, 287.691, 285.878, 286.46, 286.252, 284.652, 284.129, 284.188], title: "Full chart", style: Styles.lineChartStyleOne)
            
        }
    }
}

