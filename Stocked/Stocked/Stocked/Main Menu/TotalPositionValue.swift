//
//  TotalPositionValue.swift
//  Stocked
//
//  Created by Gabriel Ungur on 2024-02-19.
//

import UIKit

extension ViewController{
    
    func updateTotalPositionValue() {
        let totalPositionValue = textViews.reduce(0.0) { total, textView in
            let positionValue = extractPositionValue(from: textView)
            return total + positionValue
        }
        
        totalPositionValueLabel.text = String(format: "Total Position Value: $%.2f", totalPositionValue)
        
        print("Total Position Value: \(totalPositionValue)")
    }
    
    public func extractPositionValue(from textView: UITextView) -> Double {
        guard let text = textView.text else {
            print("TextView text is nil")
            return 0.0
        }

        // Split the text into lines
        let lines = text.split(separator: "\n")

        // Find the line that contains "Position Value:"
        for line in lines {
            if line.contains("Position Value:") {
                // Extract the part after the colon and trim any leading/trailing whitespaces
                let valuePart = line.split(separator: ":").last?.trimmingCharacters(in: .whitespaces)
                
                // Replace commas and dollar sign to handle formatted numbers correctly
                let cleanedValuePart = valuePart?.replacingOccurrences(of: ",", with: "").replacingOccurrences(of: "$", with: "")
                
                if let numberString = cleanedValuePart, let value = Double(numberString) {
                    print("Extracted position value: \(value)")
                    return value
                } else {
                    print("Failed to convert extracted string to Double: \(cleanedValuePart ?? "N/A")")
                }
                break // Exit the loop once the line is processed
            }
        }

        print("No line containing 'Position Value:' found")
        return 0.0
    }

    
    public func extractInitialInvestment(from textView: UITextView) -> Double {
        guard let text = textView.text else {
            return 0.0
        }
        
        // Adjusted regex pattern to match "Initial Investment:" followed by an optional comma-separated value and "USD"
        let regexPattern = "Initial Investment: ([0-9]{1,3}(?:,[0-9]{3})*(?:\\.[0-9]+)?) USD"
        
        do {
            let regex = try NSRegularExpression(pattern: regexPattern)
            let results = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
            
            if let match = results.first {
                let range = Range(match.range(at: 1), in: text)!
                let valueString = String(text[range]).replacingOccurrences(of: ",", with: "") // Remove commas
                return Double(valueString) ?? 0.0
            }
        } catch {
            print("Invalid regex pattern or error in execution")
        }
        
        return 0.0
    }

    
    func updateTotalPositionValueAndProfitLossPercentage() {
        let totalPositionValue = textViews.reduce(0.0) { $0 + extractPositionValue(from: $1) }
        let totalInitialInvestment = textViews.reduce(0.0) { $0 + extractInitialInvestment(from: $1) }
        
        // Calculate total profit or loss
        let totalProfitOrLoss = totalPositionValue - totalInitialInvestment
        
        // Determine color based on profit or loss
        var profitOrLossColor: UIColor
        
        if totalProfitOrLoss > 0 {
            profitOrLossColor = .green
        } else if totalProfitOrLoss < 0 {
            profitOrLossColor = .red
        } else {
            profitOrLossColor = .white
        }
        
        // Formatter for numbers
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal // Use decimal style to include commas
        numberFormatter.minimumFractionDigits = 2 // Minimum decimal places
        numberFormatter.maximumFractionDigits = 2 // Maximum decimal places
        
        // Title part of the display text
        let titleText = "TOTAL POSITION VALUE\n" // Using newline character to place the value on the next line
        
        // Format total position value without positive prefix
        let formattedTotalPositionValue = numberFormatter.string(from: NSNumber(value: totalPositionValue)) ?? "0.00"
        var valueText = "US$\(formattedTotalPositionValue)"
        
        // Apply positive prefix for profit/loss and percentage values
        numberFormatter.positivePrefix = "+" // Prefix for positive numbers
        
        if showPercentage {
            let percentageChange = totalInitialInvestment != 0 ? (totalProfitOrLoss / totalInitialInvestment) * 100 : 0.0
            let formattedPercentage = numberFormatter.string(from: NSNumber(value: percentageChange)) ?? "0.00"
            valueText += "\n(\(formattedPercentage)%)"
        } else {
            let formattedProfitOrLoss = numberFormatter.string(from: NSNumber(value: totalProfitOrLoss)) ?? "0.00"
            valueText += "\n(\(formattedProfitOrLoss)$)"
        }
        
        // Attributes for the title text
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 11), // Smaller font size for the title
            .foregroundColor: UIColor.lightGray // Default color for the title
        ]
        
        // Attributes for the value text
        let valueAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 24), // Larger, bold font for the value
            .foregroundColor: profitOrLossColor // Color indicating profit or loss
        ]
        
        // Combining the title and value strings into an NSMutableAttributedString
        let combinedAttributedString = NSMutableAttributedString(string: titleText, attributes: titleAttributes)
        combinedAttributedString.append(NSAttributedString(string: valueText, attributes: valueAttributes))
        
        // Ensure the label is configured to handle attributed text with multiple lines
        totalPositionValueLabel.numberOfLines = 0 // Allow unlimited lines
        totalPositionValueLabel.textAlignment = .center // Center-align the text
        
        // Update the label with the attributed string
        totalPositionValueLabel.attributedText = combinedAttributedString
        
        // Adjust the label size based on its content
        adjustLabelSizeAndPosition()
        
        // Adjust the position of the text views to be below the updated label
        adjustTextViewsPosition()
    }


    //IF YOU WANT TO UPDATE THE LABELS POSITION JUST UNCOMMENT THE CALL TO THIS FUNCTION IN SAVINGANDDELETE AND ADDBUTTON
    /*
    public func updateTotalPositionValueLabelPosition() {
        let defaultYPosition: CGFloat = 20 // This can be any default position, but it won't matter when label is hidden

        if let firstTextView = textViews.first {
            let spacingAboveFirstTextView: CGFloat = 10 // Space between the label and the first textView
            let newYPosition = firstTextView.frame.origin.y - totalPositionValueLabel.frame.height - spacingAboveFirstTextView
            totalPositionValueLabel.frame.origin.y = newYPosition
            totalPositionValueLabel.isHidden = false // Show the label
        } else {
            totalPositionValueLabel.isHidden = true // Hide the label if there are no text views
        }

        // Optionally, update the scroll view content size if needed
        updateScrollViewContentSize()
    }

     */
    
    
    @objc func totalPositionValueLabelTapped() {
        showPercentage.toggle()
        updateTotalPositionValueAndProfitLossPercentage()
        let feedbackGenerator = UISelectionFeedbackGenerator()
            feedbackGenerator.prepare()
            feedbackGenerator.selectionChanged()
    }
    
    
    
    
    func adjustLabelSizeAndPosition() {
        let labelWidth = totalPositionValueLabel.frame.width // Assuming the label width is already set
        let maxSize = CGSize(width: labelWidth, height: CGFloat.greatestFiniteMagnitude) // Max size based on width
        let requiredSize = totalPositionValueLabel.sizeThatFits(maxSize) // Calculate required size for content
        
        // Update label frame with the new required height
        totalPositionValueLabel.frame.size.height = requiredSize.height
        
        // Optionally, adjust the label's Y position if necessary, for example, to align it at the top of the screen or a container view
        // This centers the label horizontally as well
           totalPositionValueLabel.frame.origin.x = (UIScreen.main.bounds.width - labelWidth) / 2
           totalPositionValueLabel.textAlignment = .center // Ensure text is centered within the label
       }

    func adjustTextViewsPosition() {
        let spacing: CGFloat = 10 // Space between the bottom of the label and the first text view
        var newYPosition = totalPositionValueLabel.frame.maxY + spacing // Starting Y position for the first text view
        
        // Iterate over each text view and update its Y position
        for textView in textViews {
            var frame = textView.frame
            frame.origin.y = newYPosition
            textView.frame = frame
            
            // Update newYPosition for the next text view, adding spacing between text views
            newYPosition += frame.height + spacing
        }
        
        // Optionally, update the scroll view content size if these text views are within a scroll view
        updateScrollViewContentSizeIfNeeded()
    }
    
    
    
    func updateScrollViewContentSizeIfNeeded() {
        // Assuming there's a scrollView containing the label and text views
        guard let lastTextView = textViews.last else { return }
        let contentHeight = lastTextView.frame.maxY + 20 // Add some padding at the bottom
        scrollView.contentSize = CGSize(width: scrollView.frame.width, height: contentHeight)
    }
}
