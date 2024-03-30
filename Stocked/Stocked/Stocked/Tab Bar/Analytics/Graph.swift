//
//  Graph.swift
//  Stocked
//
//  Created by Gabriel Ungur on 2024-03-15.
//

import SwiftUI
import SwiftUICharts

struct DataPoint: Codable { // Ensure DataPoint conforms to Codable for UserDefaults storage
    let value: Double
    let timestamp: Date
}

enum TimeRange {
    case hour
    case day
    case week
    case month
    case threeMonth
    case ALL
}


struct Graph: View {
    
    var timeRange: TimeRange

    
    @State private var positionValues: [Double] = []
    @State private var graphID = UUID()

    private var sumOfPositionValues: Double {
        positionValues.reduce(0, +)
    }

    private func cleanupCumulativeDataForHour() {
        let oneHourAgo = Calendar.current.date(byAdding: .hour, value: -1, to: Date())!
        TextViewManager.shared.cumulativeData = TextViewManager.shared.cumulativeData.filter { $0.timestamp >= oneHourAgo }
    }
    
    private func cleanupCumulativeDataForDay() {
        let oneDayAgo = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        TextViewManager.shared.cumulativeData = TextViewManager.shared.cumulativeData.filter { $0.timestamp >= oneDayAgo }
    }
    
    
    private func cleanupCumulativeDataForWeek() {
        let oneWeekAgo = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: Date())!
        TextViewManager.shared.cumulativeData = TextViewManager.shared.cumulativeData.filter { $0.timestamp >= oneWeekAgo }
    }
    
    private func cleanupCumulativeDataForMonth() {
        let oneMonthAgo = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
        TextViewManager.shared.cumulativeData = TextViewManager.shared.cumulativeData.filter { $0.timestamp >= oneMonthAgo }
    }

    private func cleanupCumulativeDataForThreeMonths() {
        let threeMonthsAgo = Calendar.current.date(byAdding: .month, value: -3, to: Date())!
        TextViewManager.shared.cumulativeData = TextViewManager.shared.cumulativeData.filter { $0.timestamp >= threeMonthsAgo }
    }


    
    var body: some View {
        VStack {
            ZStack {
                Color(red: 24/255.0, green: 24/255.0, blue: 24/255.0)
                    .edgesIgnoringSafeArea(.all)

                var graphStyle: ChartStyle {
                       // Determine accent color based on the profit or loss
                       let firstValue = TimeRangeManager.shared.filteredData.first ?? 0
                       let lastValue = TimeRangeManager.shared.filteredData.last ?? 0
                       //First color gradient on graph
                       let dynamicAccentColor: Color = firstValue < lastValue ?  Color(red: 0.3, green: 0.9, blue: 0.7): Color(UIColor(red: 234/255.0, green: 85/255.0, blue: 69/255.0, alpha: 1.0))
                       //Second color gradient
                       let dynamicSecondGradientColor: Color = firstValue < lastValue ? Color(UIColor(red: 103/255.0, green: 205/255.0, blue: 103/255.0, alpha: 1.0)) : .red
                       
                       return ChartStyle(
                           backgroundColor: Color(red: 24/255.0, green: 24/255.0, blue: 24/255.0),
                           accentColor: dynamicAccentColor, // Use dynamically determined accent color
                           secondGradientColor: dynamicSecondGradientColor,
                           textColor: Color.white,
                           legendTextColor: Color.white,
                           dropShadowColor: Color.white.opacity(0.0)
                       )
                   }
                
                VStack {

                    LineView(data: TimeRangeManager.shared.filteredData, legend: "Total Equity", style: graphStyle)
                        .id(graphID)
                }
            }
        }
        .onAppear {
            loadCumulativeData()
            
            cleanupCumulativeDataForHour()
            cleanupCumulativeDataForDay()
            cleanupCumulativeDataForWeek()
            cleanupCumulativeDataForMonth()
            cleanupCumulativeDataForThreeMonths()
            
            print("Cumulative Data Loaded: \(TextViewManager.shared.cumulativeData)")
            
            graphID = UUID() // Refresh the chart by changing its ID
            
            self.Graph_extractPositionValues()
            print("Position Values Extracted: \(positionValues)")
            
            // Assuming you're using the custom struct approach
            let newDataPoint = DataPoint(value: sumOfPositionValues, timestamp: Date())
            TextViewManager.shared.cumulativeData.append(newDataPoint)
            print("New Data Point Added: \(newDataPoint)")
            
            print("Filtered Data: \(TimeRangeManager.shared.filteredData)")
        }

        .colorScheme(.light)
    }
    
    
    // Function to extract position values from textViews
    private func Graph_extractPositionValues() {
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
    
   

        private func loadCumulativeData() {
            guard let data = UserDefaults.standard.data(forKey: TextViewManager.shared.cumulativeDataKey) else { return }
            do {
                TextViewManager.shared.cumulativeData = try JSONDecoder().decode([DataPoint].self, from: data)
            } catch {
                print("Failed to load cumulative data: \(error)")
            }
        }
    }
/*
    struct Graph_Previews: PreviewProvider {
        static var previews: some View {
            Graph()
        }
    }
*/
