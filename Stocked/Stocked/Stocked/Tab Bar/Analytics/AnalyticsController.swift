//
//  AnalyticsController.swift
//  Stocked
//
//  Created by Gabriel Ungur on 2024-03-10.
//
import UIKit
import SwiftUI

class TimeRangeManager {
    static let shared = TimeRangeManager()
    
    var currentRange: TimeRange = .ALL // Default value
    
    var filteredData: [Double] {
        let startDate: Date
        var dataPoints: [Double] = [0]  // Initialize the array with a starting value of 0

        switch currentRange {
            
        case .hour:
            startDate = Calendar.current.date(byAdding: .hour, value: -1, to: Date())!

            var intervalDates: [Date] = []
            for offset in stride(from: 0, to: 60 * 60, by: 15) { // 60 minutes * 60 seconds, every 15 seconds
                if let intervalDate = Calendar.current.date(byAdding: .second, value: offset, to: startDate) {
                    intervalDates.append(intervalDate)
                }
            }

            var dataPoints: [Double] = []
            for intervalDate in intervalDates {
                if let closestDataPoint = TextViewManager.shared.cumulativeData.min(by: { abs($0.timestamp.timeIntervalSince(intervalDate)) < abs($1.timestamp.timeIntervalSince(intervalDate)) }) {
                    dataPoints.append(closestDataPoint.value)
                }
            }

            // Remove consecutive duplicates from dataPoints
            dataPoints = dataPoints.enumerated().filter { index, value in
                index == 0 || value != dataPoints[index - 1]
            }.map { $0.1 }  // Extract the values
            
            // Check if the first value is 0 and if it's been there for over an hour, remove it
            if dataPoints.first == 0 {
                if let firstNonZeroTimestamp = TextViewManager.shared.cumulativeData.first(where: { $0.value != 0 })?.timestamp {
                    let oneHourAgo = Calendar.current.date(byAdding: .hour, value: -1, to: firstNonZeroTimestamp)!
                    if TextViewManager.shared.cumulativeData.first?.timestamp ?? Date() < oneHourAgo {
                        dataPoints.removeFirst()
                    }
                }
            }

            return dataPoints



            
        case .day:
            startDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
            
            var intervalDates: [Date] = []
            
            for offset in stride(from: 0, to: 24 * 60, by: 15) { // 24 hours * 60 minutes, every 15 minutes
                if let intervalDate = Calendar.current.date(byAdding: .minute, value: offset, to: startDate) {
                    intervalDates.append(intervalDate)
                }
            }
            
            var dataPoints: [Double] = [0]  // Initialize the array with a starting value of 0
            for intervalDate in intervalDates {
                if let closestDataPoint = TextViewManager.shared.cumulativeData.min(by: { abs($0.timestamp.timeIntervalSince(intervalDate)) < abs($1.timestamp.timeIntervalSince(intervalDate)) }) {
                    dataPoints.append(closestDataPoint.value)
                }
            }
            
            // Remove consecutive duplicates from dataPoints
            dataPoints = dataPoints.enumerated().filter { index, value in
                index == 0 || value != dataPoints[index - 1]
            }.map { $0.1 }  // Extract the values
            
            return dataPoints

            
        case .week:
            startDate = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
            
            var intervalDates: [Date] = []
            for offset in stride(from: 0, to: 7 * 24, by: 1) { // 7 days * 24 hours, every hour
                if let intervalDate = Calendar.current.date(byAdding: .hour, value: offset, to: startDate) {
                    intervalDates.append(intervalDate)
                }
            }
            
            var dataPoints: [Double] = [0]  // Initialize the array with a starting value of 0
            for intervalDate in intervalDates {
                if let closestDataPoint = TextViewManager.shared.cumulativeData.min(by: { abs($0.timestamp.timeIntervalSince(intervalDate)) < abs($1.timestamp.timeIntervalSince(intervalDate)) }) {
                    dataPoints.append(closestDataPoint.value)
                }
            }
            
            // Remove consecutive duplicates from dataPoints
            dataPoints = dataPoints.enumerated().filter { index, value in
                index == 0 || value != dataPoints[index - 1]
            }.map { $0.1 }  // Extract the values
            
            return dataPoints

            
            
            
        case .month:
            startDate = Calendar.current.date(byAdding: .month, value: -1, to: Date())!

            let dailyDataPoints = Dictionary(grouping: TextViewManager.shared.cumulativeData.filter { $0.timestamp >= startDate }) { (dataPoint) -> DateComponents in
                return Calendar.current.dateComponents([.year, .month, .day], from: dataPoint.timestamp)
            }.compactMapValues { dataPoints -> Double? in
                // Select the last data point for the day
                return dataPoints.last?.value
            }

            // Convert DateComponents back to Date for sorting, then map to the corresponding values
            var sortedDataPoints = dailyDataPoints.keys.compactMap { Calendar.current.date(from: $0) }.sorted().compactMap { date -> Double? in
                let components = Calendar.current.dateComponents([.year, .month, .day], from: date)
                return dailyDataPoints[components]
            }

            // Ensure the first value is 0
            if sortedDataPoints.isEmpty || sortedDataPoints[0] != 0 {
                sortedDataPoints.insert(0, at: 0)
            }

            // Remove consecutive duplicates from sortedDataPoints
            sortedDataPoints = sortedDataPoints.enumerated().filter { index, value in
                index == 0 || value != sortedDataPoints[index - 1]
            }.map { $0.1 }  // Extract the values

            return sortedDataPoints

            
            
        case .threeMonth:
            startDate = Calendar.current.date(byAdding: .month, value: -3, to: Date())!

            var thirtySixHourlyDataPoints: [Double] = []
            for offset in stride(from: 0, to: 90 * 24, by: 36) { // 90 days * 24 hours, every 36 hours
                if let intervalDate = Calendar.current.date(byAdding: .hour, value: offset, to: startDate) {
                    // Find the data point closest to this 36-hour interval
                    if let closestDataPoint = TextViewManager.shared.cumulativeData.min(by: { abs($0.timestamp.timeIntervalSince(intervalDate)) < abs($1.timestamp.timeIntervalSince(intervalDate)) }) {
                        thirtySixHourlyDataPoints.append(closestDataPoint.value)
                    }
                }
            }

            // Ensure the first value is 0
            if thirtySixHourlyDataPoints.isEmpty || thirtySixHourlyDataPoints[0] != 0 {
                thirtySixHourlyDataPoints.insert(0, at: 0)
            }

            // Remove consecutive duplicates from thirtySixHourlyDataPoints
            thirtySixHourlyDataPoints = thirtySixHourlyDataPoints.enumerated().filter { index, value in
                index == 0 || value != thirtySixHourlyDataPoints[index - 1]
            }.map { $0.1 }  // Extract the values

            return thirtySixHourlyDataPoints

        case .ALL:
            guard let startDate = TextViewManager.shared.cumulativeData.first?.timestamp else { return [] }

            var threeAndHalfDayDataPoints: [Double] = []
            let intervalHours = 3.5 * 24 // 3.5 days in hours

            var intervalDate = startDate
            while intervalDate < Date() { // Loop until the current date
                if let closestDataPoint = TextViewManager.shared.cumulativeData.min(by: { abs($0.timestamp.timeIntervalSince(intervalDate)) < abs($1.timestamp.timeIntervalSince(intervalDate)) }) {
                    threeAndHalfDayDataPoints.append(closestDataPoint.value)
                }

                // Move to the next interval
                if let nextIntervalDate = Calendar.current.date(byAdding: .hour, value: Int(intervalHours), to: intervalDate) {
                    intervalDate = nextIntervalDate
                } else {
                    break // In case of a calculation error, prevent an infinite loop
                }
            }

            // Ensure the first value is 0
            if threeAndHalfDayDataPoints.isEmpty || threeAndHalfDayDataPoints[0] != 0 {
                threeAndHalfDayDataPoints.insert(0, at: 0)
            }

            // Remove consecutive duplicates from threeAndHalfDayDataPoints
            threeAndHalfDayDataPoints = threeAndHalfDayDataPoints.enumerated().filter { index, value in
                index == 0 || value != threeAndHalfDayDataPoints[index - 1]
            }.map { $0.1 } // Extract the values

            return threeAndHalfDayDataPoints
        }

        return TextViewManager.shared.cumulativeData
            .filter { $0.timestamp >= startDate }
            .map { $0.value }
    }
    
    private init() {} // Private initialization to ensure singleton instance
}



class AnalyticsController: UIViewController {
  
    
    @IBOutlet weak var hostingContainerView: UIView!
    
    var currentHostingController: UIHostingController<AnyView>?

    //Creating buttons that represent timeframes
    let oneHourButton = UIButton(type: .system)
    let oneDayButton = UIButton(type: .system)
    let oneWeekButton = UIButton(type: .system)
    let oneMonthButton = UIButton(type: .system)
    let threeMonthButton = UIButton(type: .system)
    let ALLButton = UIButton(type: .system)
    
    @IBOutlet weak var analyticScrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Perform any additional setup after loading the view.
        setupUI()
        
        //Setting width and height constraints to oneHourButton
        oneHourButton.widthAnchor.constraint(equalToConstant: 45).isActive = true
        oneHourButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }

    func setupUI() {
        // Configure UI elements such as labels, buttons, charts, etc.
        let analyticsLabel = UILabel()
        analyticsLabel.text = "Analytics"
        analyticsLabel.textAlignment = .center
        analyticsLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        analyticsLabel.translatesAutoresizingMaskIntoConstraints = false
        analyticScrollView.addSubview(analyticsLabel) // Add the label to the scrollView
        
        // Center the label on the X-axis and position it on the Y-axis as desired
        NSLayoutConstraint.activate([
            analyticsLabel.centerXAnchor.constraint(equalTo: analyticScrollView.centerXAnchor),
            analyticsLabel.topAnchor.constraint(equalTo: analyticScrollView.topAnchor, constant: 20), // Keep the top spacing as you have it
            // It's not necessary to set the width anchor since the label's intrinzsic content size will take care of its width
        ])
        
        
        // Create the "1H" button
        oneHourButton.setTitle("1H", for: .normal)
        oneHourButton.translatesAutoresizingMaskIntoConstraints = false
        // Set the button's title color to white for the normal state
        oneHourButton.setTitleColor(.white, for: .normal)
        
        
        // Add the button to the scrollView
        analyticScrollView.addSubview(oneHourButton)
        
        // Define the constraints for oneHourButton
        let oneHourButtonConstraints = [
            oneHourButton.leadingAnchor.constraint(equalTo: analyticScrollView.leadingAnchor, constant: 15), // 15 points from the left edge of the scrollView
            oneHourButton.topAnchor.constraint(equalTo: analyticsLabel.bottomAnchor, constant: 40) // Positioned under the analyticsLabel with
        ]
        
        // Activate the constraints
        NSLayoutConstraint.activate(oneHourButtonConstraints)
        
        
        
        // Create the "1D" button
            oneDayButton.setTitle("1D", for: .normal)
            oneDayButton.translatesAutoresizingMaskIntoConstraints = false
            oneDayButton.setTitleColor(.white, for: .normal) // Set title color to black (or any color that suits your design)

            // Add the "1D" button to the scrollView
            analyticScrollView.addSubview(oneDayButton)

            // Define the constraints for oneDayButton
            NSLayoutConstraint.activate([
                oneDayButton.leadingAnchor.constraint(equalTo: oneHourButton.trailingAnchor, constant: 25), // Positioned 10 points to the right of the "1D" button
                oneDayButton.topAnchor.constraint(equalTo: analyticsLabel.bottomAnchor, constant: 40), // Aligned with the "1D" button's top
                oneDayButton.widthAnchor.constraint(equalTo: oneHourButton.widthAnchor), // Optional: Ensure "1W" button has the same width as "1D" button
                oneDayButton.heightAnchor.constraint(equalTo: oneHourButton.heightAnchor) // Optional: Ensure "1W" button has the same height as "1D" button
            ])
        
        
        // Create the "1W" button
            oneWeekButton.setTitle("1W", for: .normal)
            oneWeekButton.translatesAutoresizingMaskIntoConstraints = false
            oneWeekButton.setTitleColor(.white, for: .normal) // Set title color to black (or any color that suits your design)

            // Add the "1W" button to the scrollView
            analyticScrollView.addSubview(oneWeekButton)

            // Define the constraints for oneDayButton
            NSLayoutConstraint.activate([
                oneWeekButton.leadingAnchor.constraint(equalTo: oneDayButton.trailingAnchor, constant: 25), // Positioned 10 points to the right of the "1D" button
                oneWeekButton.topAnchor.constraint(equalTo: analyticsLabel.bottomAnchor, constant: 40), // Aligned with the "1D" button's top
                oneWeekButton.widthAnchor.constraint(equalTo: oneDayButton.widthAnchor), // Optional: Ensure "1W" button has the same width as "1D" button
                oneWeekButton.heightAnchor.constraint(equalTo: oneDayButton.heightAnchor) // Optional: Ensure "1W" button has the same height as "1D" button
            ])
        
        // Create the "1M" button
            oneMonthButton.setTitle("1M", for: .normal)
            oneMonthButton.translatesAutoresizingMaskIntoConstraints = false
            oneMonthButton.setTitleColor(.white, for: .normal) // Set title color to black (or any color that suits your design)

            // Add the "1M" button to the scrollView
            analyticScrollView.addSubview(oneMonthButton)

            // Define the constraints for oneDayButton
            NSLayoutConstraint.activate([
                oneMonthButton.leadingAnchor.constraint(equalTo: oneWeekButton.trailingAnchor, constant: 25), // Positioned 10 points to the right of the "1D" button
                oneMonthButton.topAnchor.constraint(equalTo: analyticsLabel.bottomAnchor, constant: 40), // Aligned with the "1D" button's top
                oneMonthButton.widthAnchor.constraint(equalTo: oneWeekButton.widthAnchor), // Optional: Ensure "1W" button has the same width as "1D" button
                oneMonthButton.heightAnchor.constraint(equalTo: oneWeekButton.heightAnchor) // Optional: Ensure "1W" button has the same height as "1D" button
            ])
        
        
        // Create the "3M" button
        threeMonthButton.setTitle("3M", for: .normal)
        threeMonthButton.translatesAutoresizingMaskIntoConstraints = false
        threeMonthButton.setTitleColor(.white, for: .normal) // Set title color to black (or any color that suits your design)

        // Add the "3M" button to the scrollView
        analyticScrollView.addSubview(threeMonthButton)

        // Define the constraints for oneDayButton
        NSLayoutConstraint.activate([
            threeMonthButton.leadingAnchor.constraint(equalTo: oneMonthButton.trailingAnchor, constant: 25), // Positioned 10 points to the right of the "1D" button
            threeMonthButton.topAnchor.constraint(equalTo: analyticsLabel.bottomAnchor, constant: 40), // Aligned with the "1D" button's top
            threeMonthButton.widthAnchor.constraint(equalTo: oneMonthButton.widthAnchor), // Optional: Ensure "1W" button has the same width as "1D" button
            threeMonthButton.heightAnchor.constraint(equalTo: oneMonthButton.heightAnchor) // Optional: Ensure "1W" button has the same height as "1D" button
        ])
        
        
        // Create the "ALL" button
        
        ALLButton.setTitle("ALL", for: .normal)
        ALLButton.translatesAutoresizingMaskIntoConstraints = false
        ALLButton.setTitleColor(.white, for: .normal) // Set title color to black (or any color that suits your design)

        // Add the "1W" button to the scrollView
        analyticScrollView.addSubview(ALLButton)

        // Define the constraints for oneDayButton
        NSLayoutConstraint.activate([
            ALLButton.leadingAnchor.constraint(equalTo: threeMonthButton.trailingAnchor, constant: 25), // Positioned 10 points to the right of the "1D" button
            ALLButton.topAnchor.constraint(equalTo: analyticsLabel.bottomAnchor, constant: 40), // Aligned with the "1D" button's top
            ALLButton.widthAnchor.constraint(equalTo: threeMonthButton.widthAnchor), // Optional: Ensure "1W" button has the same width as "1D" button
            ALLButton.heightAnchor.constraint(equalTo: threeMonthButton.heightAnchor) // Optional: Ensure "1W" button has the same height as "1D" button
        ])
        
        
        // Add target-action for touch up inside event for each button
           oneHourButton.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
           oneDayButton.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
           oneWeekButton.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
           oneMonthButton.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
           threeMonthButton.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
           ALLButton.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
    }

    func updateHostingControllerRootView(to view: AnyView) {
        // Remove the existing hosting controller if it exists
        currentHostingController?.willMove(toParent: nil)
        currentHostingController?.view.removeFromSuperview()
        currentHostingController?.removeFromParent()

        // Clear any residual subviews from the hostingContainerView
        hostingContainerView.subviews.forEach { $0.removeFromSuperview() }

        // Create a new hosting controller with the specified view
        let newHostingController = UIHostingController(rootView: view)

        // Add the new hosting controller as a child view controller
        addChild(newHostingController)
        hostingContainerView.addSubview(newHostingController.view)

        // Ensure the view fully occupies the hosting container view
        newHostingController.view.frame = hostingContainerView.bounds
        newHostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        // Complete the addition of the new hosting controller
        newHostingController.didMove(toParent: self)

        // Update the current hosting controller reference
        currentHostingController = newHostingController
    }


    
    @objc func buttonTapped(_ sender: UIButton) {
        // Array of all buttons for easy access
        let buttons = [oneHourButton, oneDayButton, oneWeekButton, oneMonthButton, threeMonthButton, ALLButton]

        // Determine the current time range based on the button tapped and set it in TimeRangeManager
        let currentTimeRange: TimeRange
        switch sender {
        case oneHourButton:
            currentTimeRange = .hour
        case oneDayButton:
            currentTimeRange = .day
        case oneWeekButton:
            currentTimeRange = .week
        case oneMonthButton:
            currentTimeRange = .month
        case threeMonthButton:
            currentTimeRange = .threeMonth
        case ALLButton:
            currentTimeRange = .ALL
        default:
            return // If none of the cases match, exit the function
        }

        // Set the current range in TimeRangeManager
        TimeRangeManager.shared.currentRange = currentTimeRange

        
        // Determine accent color based on the profit or loss
        let firstValue = TimeRangeManager.shared.filteredData.first ?? 0
        let lastValue = TimeRangeManager.shared.filteredData.last ?? 0

        // Determine if the first value is less than the last value in filteredData
        let isIncreasing = firstValue < lastValue

        // Loop through all buttons
        for button in buttons {
            // Reset button styles to default
            resetButtonStyles(button)

            // If the button is the sender, apply the selected styles
            if button == sender {
                applySelectedButtonStyles(button, isIncreasing: isIncreasing)
            }
        }

        // Update the graph based on the selected time range
        let graphView = Graph(timeRange: currentTimeRange)
        updateHostingControllerRootView(to: AnyView(graphView))
    }

    func resetButtonStyles(_ button: UIButton) {
        button.transform = .identity
        button.backgroundColor = .clear
        button.layer.cornerRadius = 0
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
    }

    func applySelectedButtonStyles(_ button: UIButton, isIncreasing: Bool) {
        // Green if increasing otherwise red
        button.backgroundColor = isIncreasing ? UIColor(red: 103/255.0, green: 205/255.0, blue: 103/255.0, alpha: 1.0) : UIColor(red: 234/255.0, green: 85/255.0, blue: 69/255.0, alpha: 1.0)
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
    }




 
    

    //Pie Chart
    @IBSegueAction func graphSwiftUIView(_ coder: NSCoder) -> UIViewController? {
        return UIHostingController(coder: coder, rootView: PieChart())
    }
    
    //Line Graph
    @IBSegueAction func chartSwiftUIView(_ coder: NSCoder) -> UIViewController? {
        let graphView = Graph(timeRange: TimeRangeManager.shared.currentRange)
            return UIHostingController(coder: coder, rootView: graphView)
        }
    
    
    @IBSegueAction func smallGraphSwiftUIView(_ coder: NSCoder) -> UIViewController? {
        return UIHostingController(coder: coder, rootView: smallGraph())
    }
    
    
    
}
