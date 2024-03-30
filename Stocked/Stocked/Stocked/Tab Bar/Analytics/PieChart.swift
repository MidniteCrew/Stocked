//
//  Graph.swift
//  Stocked
//
//  Created by Gabriel Ungur on 2024-03-15.
//

import SwiftUI
import SwiftUICharts

struct PieChart: View {
    // Create a @State property to hold the extracted position values
    @State private var positionValues: [Double] = []
    @State private var chartID = UUID()  // Add this line

    var body: some View {
        VStack {
            // Conditionally render the PieChartView if positionValues is not empty
            if !positionValues.isEmpty {
                PieChartView(data: positionValues, title: "Portfolio", style: Styles.custom_style, form: ChartForm.large)
                                   .id(chartID)
                
            } else {
                Text("No data available")
                    .foregroundColor(.gray)
            }
        }
        .onAppear {
            // When the view appears, extract position values from textViews
            PieChart_extractPositionValues()
            chartID = UUID()  // Add this line to update the ID each time the view appears
        }
    }
    
    // Function to extract position values from textViews
    private func PieChart_extractPositionValues() {
        // Clear existing position values
        positionValues.removeAll()
        
        // Loop through textViews
        for textView in TextViewManager.shared.textViews {
            // Extract text from textView
            guard let text = textView.text else { continue }
            
            // Split text by newline characters
            let lines = text.components(separatedBy: .newlines)
            
            // Loop through lines
            for line in lines {
                // Check if line starts with "Position Value: "
                if line.starts(with: "Position Value: ") {
                    // Extract position value string
                    let valueString = line.replacingOccurrences(of: "Position Value: ", with: "")
                    
                    // Convert position value string to Double
                    if let positionValue = Double(valueString.replacingOccurrences(of: ",", with: "")) {
                        positionValues.append(positionValue)
                    }
                }
            }
        }
        
        // Print the extracted position values for debugging
        print("Extracted Position Values:", positionValues)
    }
}

struct Analytic_Previews: PreviewProvider {
    static var previews: some View {
        PieChart()
    }
}

