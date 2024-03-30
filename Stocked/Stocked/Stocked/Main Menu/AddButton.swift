//
//  AddButton.swift
//  Stocked
//
//  Created by Gabriel Ungur on 2024-02-19.
//

import UIKit


/* This is never used. I can simply add it back if i want to ask user if its stock or crypto
 public func presentStockEntryAlert() {
     let alertController = UIAlertController(title: "New Stock Entry", message: "Enter details", preferredStyle: .alert)

     // Add text fields for stock entry details
     alertController.addTextField { textField in
         textField.placeholder = "Stock Ticker"
     }
     alertController.addTextField { textField in
         textField.placeholder = "Initial Investment (USD)"
         textField.keyboardType = .decimalPad
     }
     alertController.addTextField { textField in
         textField.placeholder = "Fees Paid (USD)"
         textField.keyboardType = .decimalPad
     }
     alertController.addTextField { textField in
         textField.placeholder = "Price Per Share (USD)"
         textField.keyboardType = .decimalPad
     }
     // Add a new text field for the Platform input
     alertController.addTextField { textField in
         textField.placeholder = "Platform"
     }

     let confirmAction = UIAlertAction(title: "Create", style: .default) { [weak self] _ in
         guard let self = self,
               let textFields = alertController.textFields,
               let stockSymbol = textFields[0].text, !stockSymbol.isEmpty,
               let initialInvestment = textFields[1].text, !initialInvestment.isEmpty,
               let feesPaid = textFields[2].text, !feesPaid.isEmpty,
               let pricePerShare = textFields[3].text, !pricePerShare.isEmpty,
               let platform = textFields[4].text, !platform.isEmpty else {
             // Handle invalid input
             return
         }

         // Append the platform name to the array and save to UserDefaults
         self.platforms.append(platform)
         UserDefaults.standard.set(self.platforms, forKey: "SavedPlatforms")
         UserDefaults.standard.synchronize()

         // Assuming you have a function to fetch the stock price
         self.fetchStockPrice(for: stockSymbol) { stockPrice in
             guard let stockPrice = stockPrice else {
                 // Handle error - stock price not fetched
                 return
             }

             // Now that you have the stockPrice, call createTextView
             DispatchQueue.main.async {
                 self.createTextView(stockName: stockSymbol, initialInvestment: initialInvestment, feesPaid: feesPaid, pricePerShare: pricePerShare, stockPrice: stockPrice, platform: platform)

                 // Save the stock entry to UserDefaults
                 self.saveStockEntryToUserDefaults(stockName: stockSymbol, initialInvestment: initialInvestment, feesPaid: feesPaid, pricePerShare: pricePerShare, stockPrice: stockPrice, platform: platform)
             }
         }
     }

     let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

     alertController.addAction(confirmAction)
     alertController.addAction(cancelAction)

     self.present(alertController, animated: true)
 }
 */




extension ViewController{
    
    
    public func presentCryptocurrencyEntryAlert(withPreviousInput input: [String?]? = nil) {
        let alertController = UIAlertController(title: "New Entry", message: "Enter details", preferredStyle: .alert)
        
        var textFields: [UITextField] = [] // Store text fields locally
        
        // Add text fields for cryptocurrency details
        alertController.addTextField { textField in
            textField.placeholder = "Ticker"
            if let previousInput = input?[0] {
                textField.text = previousInput
            }
            textFields.append(textField)
        }
        alertController.addTextField { textField in
            textField.placeholder = "Initial Investment (USD)"
            textField.keyboardType = .decimalPad
            if let previousInput = input?[1] {
                textField.text = previousInput
            }
            textFields.append(textField)
        }
        alertController.addTextField { textField in
            textField.placeholder = "Fees Paid (USD)"
            textField.keyboardType = .decimalPad
            if let previousInput = input?[2] {
                textField.text = previousInput
            }
            textFields.append(textField)
        }
        alertController.addTextField { textField in
            textField.placeholder = "Price Per Unit (USD)"
            textField.keyboardType = .decimalPad
            if let previousInput = input?[3] {
                textField.text = previousInput
            }
            textFields.append(textField)
        }
        // Add a new text field for the Platform input
        alertController.addTextField { textField in
            textField.placeholder = "Platform"
            if let previousInput = input?[4] {
                textField.text = previousInput
            }
            textFields.append(textField)
        }
        
        let confirmAction = UIAlertAction(title: "Create", style: .default) { _ in
            guard let stockSymbol = textFields[0].text, !stockSymbol.isEmpty,
                let initialInvestment = textFields[1].text, !initialInvestment.isEmpty,
                let feesPaid = textFields[2].text, !feesPaid.isEmpty,
                let pricePerShare = textFields[3].text, !pricePerShare.isEmpty,
                let platform = textFields[4].text, !platform.isEmpty else {
                    // Show the alert again with the previous input
                    self.presentCryptocurrencyEntryAlert(withPreviousInput: textFields.map { $0.text })
                    return
            }
            
            // Proceed with creating the text view and other actions
            self.fetchStockDetails(for: stockSymbol, initialInvestment: initialInvestment, feesPaid: feesPaid, pricePerShare: pricePerShare, platform: platform)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }

    public func centerAlignedParagraphStyle() -> NSMutableParagraphStyle {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        return paragraphStyle
    }
    
    public func leftAlignedParagraphStyle() -> NSMutableParagraphStyle {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        return paragraphStyle
    }
    
    public func calculateXPositionForTextView() -> CGFloat {
        let textViewWidth: CGFloat = 300
        return (self.scrollView.frame.width - textViewWidth) / 2
    }
    
    public func createTextView(stockName: String, initialInvestment: String, feesPaid: String, pricePerShare: String, stockPrice: Double, platform: String) {
            let newTextView = UITextView()
            
            
            // Define a starting offset to push the first UITextView further down the screen
            let startingOffset: CGFloat = 150 // Adjust this value to position the first UITextView lower
               
            
        let stockData = StockData(stockName: stockName, initialInvestment: initialInvestment, feesPaid: feesPaid, pricePerShare: pricePerShare, stockPrice: stockPrice, platform: platform)
            textViewToStockData[newTextView] = stockData
        
            // Calculate the y position based on existing text views and the starting offset
            let yOffset = self.textViews.reduce(startingOffset) { $0 + $1.frame.height + self.spacing }
          
            let textViewWidth: CGFloat = 300
            let xPosition = calculateXPositionForTextView()
            
            newTextView.frame = CGRect(x: xPosition, y: yOffset, width: textViewWidth, height: self.textViewHeight)
                
            
            newTextView.backgroundColor = UIColor(red: 45/255, green: 45/255, blue: 45/255, alpha: 1.0)
            newTextView.isEditable = false
            newTextView.isSelectable = false
            newTextView.layer.cornerRadius = 10
            newTextView.clipsToBounds = true
            
            // Convert input strings to Double for calculation
            guard let investment = Double(initialInvestment),
                  let fees = Double(feesPaid),
                  let pricePerShareValue = Double(pricePerShare) else {
                // Handle the error if conversion fails
                print("Invalid input")
                return
            }
            
            // Calculate the quantity of shares
            let quantityOfShares = (investment - fees) / pricePerShareValue
            
            // Calculate the current value of the investment
            let currentValueOfInvestment = quantityOfShares * stockPrice
            
            // Calculate the profit or loss
            let profitOrLoss = currentValueOfInvestment - investment
            
            // Calculate the profit/loss percentage based on current stock value and initial investment
            let profitOrLossPercentage = ((currentValueOfInvestment - investment) / investment) * 100
            
            // Format the profit/loss amount with a + or - sign
            let signedProfitOrLossString: String
            if profitOrLoss > 0 {
                signedProfitOrLossString = "+\(String(format: "%.2f", profitOrLoss))"
            } else if profitOrLoss < 0 {
                signedProfitOrLossString = "-\(String(format: "%.2f", -profitOrLoss))"
            } else {
                signedProfitOrLossString = "\(String(format: "%.2f", profitOrLoss))"
            }
            
            // Round the quantity of shares and position value to two decimal places
            let quantityOfSharesString = String(format: "%.2f", quantityOfShares)
            let currentValueString = String(format: "%.2f", currentValueOfInvestment)
            
            // Format the profit/loss percentage with the appropriate sign and parentheses
            let formattedProfitOrLossPercentage: String
            if profitOrLossPercentage > 0 {
                formattedProfitOrLossPercentage = "(+\(String(format: "%.2f", profitOrLossPercentage))%)"
            } else if profitOrLossPercentage < 0 {
                formattedProfitOrLossPercentage = "(-\(String(format: "%.2f", -profitOrLossPercentage))%)"
            } else {
                formattedProfitOrLossPercentage = "(\(String(format: "%.2f", profitOrLossPercentage))%)"
            }
            
            // Determine text color and shadow based on profit or loss
            var profitOrLossColor: UIColor = .black // Default to black
           // var shadowColor: CGColor = UIColor.clear.cgColor // Default to clear shadow
            
            if profitOrLoss > 0 {
                // Profit, set text color to green and add green shadow
                profitOrLossColor = UIColor(red: 0, green: 0.7, blue: 0, alpha: 1.0) // Adjust the green value (second parameter) as needed
               // shadowColor = UIColor.green.cgColor
            } else if profitOrLoss < 0 {
                // Loss, set text color to red and add red shadow
                profitOrLossColor = .red
              //  shadowColor = UIColor.red.cgColor
            }
            
            
            
            
            
            
            
            // Create an NSMutableAttributedString for the stock name
            let boldAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 18),
                .paragraphStyle: centerAlignedParagraphStyle(),
                .foregroundColor:UIColor(red: 245/255, green: 245/255, blue: 220/255, alpha: 1.0) // Cream color
            ]
            let boldAttributedString = NSMutableAttributedString(string: "\(stockName)\n\n", attributes: boldAttributes)
            
            // Format the stock price
            let priceString = String(format: "%.2f", stockPrice)
            
            
            
            let whiteColorAttribute: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 16),
                .paragraphStyle: leftAlignedParagraphStyle(),
                .foregroundColor: UIColor.white // Use blue color for these specific values
            ]
        
        
            // Create a NumberFormatter for formatting numbers with commas
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal

            

                
           

            // Market Price value in blue
            let marketPriceAttributedString = NSAttributedString(string: priceString + " USD\n", attributes: whiteColorAttribute)

            // Position Value in blue
            let positionValueAttributedString = NSAttributedString(string: currentValueString + " USD\n", attributes: whiteColorAttribute)

            
            
            // Create a regular NSAttributedString for the rest of the details in their default color
            let regularAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 16),
                .paragraphStyle: leftAlignedParagraphStyle(),
                .foregroundColor:UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1.0) //Cream color
            ]
            let regularText = "Initial Investment: "
            let sharesText = "Quantity of Shares: "
            let marketPriceText = "Market Price: "
            let positionValueText = "Position Value: "
            let profitLossText = "Profit/Loss: "

            let regularAttributedString = NSAttributedString(string: regularText, attributes: regularAttributes)

            // Create a separate NSAttributedString for the signed profit/loss amount with the determined text color
            let profitOrLossAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 16), // You can adjust the font size if needed
                .paragraphStyle: leftAlignedParagraphStyle(),
                .foregroundColor: profitOrLossColor // Set text color here
            ]
            let profitOrLossAttributedString = NSAttributedString(string: signedProfitOrLossString + " CAD", attributes: profitOrLossAttributes)
            
            // Create a separate NSAttributedString for the profit/loss percentage with parentheses and the determined text color
            let profitOrLossPercentageAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 16), // You can adjust the font size if needed
                .paragraphStyle: leftAlignedParagraphStyle(),
                .foregroundColor: profitOrLossColor // Set text color here
            ]
            let profitOrLossPercentageAttributedString = NSAttributedString(string: formattedProfitOrLossPercentage, attributes: profitOrLossPercentageAttributes)
            
            // Initial Investment label and value
            let initialInvestmentLabelAttributedString = NSAttributedString(string: regularText, attributes: regularAttributes)
            boldAttributedString.append(initialInvestmentLabelAttributedString)
        
            // Convert the initialInvestment string to a Double, then back to a formatted string
            if let investmentAmount = Double(initialInvestment), let formattedInvestment = numberFormatter.string(from: NSNumber(value: investmentAmount)) {
            // Use formattedInvestment where you need the formatted initial investment string
            let initialInvestmentAttributedString = NSAttributedString(string: "\(formattedInvestment) USD\n", attributes: whiteColorAttribute)
            boldAttributedString.append(initialInvestmentAttributedString) // Blue-colored value
            // Add this attributed string to your text view content where appropriate
            } else {
                // Handle the error if conversion fails
                print("Invalid input for initial investment")
            }
        


            // Quantity of Shares label and value
            let quantityOfSharesLabelAttributedString = NSAttributedString(string: sharesText, attributes: regularAttributes)
            boldAttributedString.append(quantityOfSharesLabelAttributedString)
            // Format the quantity of shares with the number formatter
            if let formattedQuantityOfShares = numberFormatter.string(from: NSNumber(value: quantityOfShares)) {
            // Use formattedQuantityOfShares for displaying the quantity of shares
            let quantityOfSharesAttributedString = NSAttributedString(string: "\(formattedQuantityOfShares) shares\n", attributes: whiteColorAttribute)

            // Append formatted quantity of shares to the boldAttributedString
            boldAttributedString.append(quantityOfSharesAttributedString)
            } else {
            // Handle the error if conversion fails
            print("Error formatting the quantity of shares")
            }

            // Market Price label and value
            let marketPriceLabelAttributedString = NSAttributedString(string: marketPriceText, attributes: regularAttributes)
            boldAttributedString.append(marketPriceLabelAttributedString)
            boldAttributedString.append(marketPriceAttributedString) // Blue-colored value

            // Position Value label and value
            let positionValueLabelAttributedString = NSAttributedString(string: positionValueText, attributes: regularAttributes)
            boldAttributedString.append(positionValueLabelAttributedString)
            boldAttributedString.append(positionValueAttributedString) // Blue-colored value

            // Profit/Loss label, value, and percentage
            let profitLossLabelAttributedString = NSAttributedString(string: profitLossText, attributes: regularAttributes)
            boldAttributedString.append(profitLossLabelAttributedString)
            boldAttributedString.append(profitOrLossAttributedString) // Already has its color set in the original code
            boldAttributedString.append(profitOrLossPercentageAttributedString) // Already has its color set in the original code


            
            // Set the combined attributed string to the UITextView
            newTextView.attributedText = boldAttributedString
            
            newTextView.delegate = self
            
            // Apply shadow to the UITextView's layer
            newTextView.layer.masksToBounds = false
           // newTextView.layer.shadowColor = shadowColor
            newTextView.layer.shadowOffset = CGSize(width: 0, height: 4) // Adjust shadow offset as needed
            newTextView.layer.shadowOpacity = 0.5 // Adjust shadow opacity as needed
            newTextView.layer.shadowRadius = 4 // Adjust shadow radius as needed
            
            // Calculate the size that best fits the specified constraints
            let fittingSize = CGSize(width: newTextView.frame.width, height: CGFloat.greatestFiniteMagnitude)
            let size = newTextView.sizeThatFits(fittingSize)
            
            // Update the frame of the text view to accommodate the content size
            newTextView.frame.size.height = size.height
            
            // Add a long press gesture recognizer for reordering
            let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture(_:)))
            newTextView.addGestureRecognizer(longPressRecognizer)
            
            // Add the text view to the scrollView
            self.scrollView.addSubview(newTextView)
            
            // Add the new text view to the array
            self.textViews.append(newTextView)
            
            // Update the content size of the scroll view
            self.updateScrollViewContentSize()
            
            // Disable scrolling for the UITextView
            newTextView.isScrollEnabled = false
            
            // Add a tap gesture recognizer to make the UITextView tappable
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.textViewTapped(_:)))
            newTextView.addGestureRecognizer(tapGesture)
            
            
            let stockSymbol = stockSymbolMapping[stockName] ?? stockName
            textViewToStockSymbol[newTextView] = stockSymbol
            
            // Debugging print
            print("Created TextView for \(stockName) with symbol \(stockSymbol)")
            
            
            self.updateTotalPositionValueAndProfitLossPercentage()
            // Update label position
            
       //   updateTotalPositionValueLabelPosition()
            
            // Right before the end of the createTextView function
            addTextView(newTextView, forPlatform: platform)

            // Debugging print to confirm the association
               print("Associated UITextView for \(stockName) with platform \(platform)")
        
            refreshStockData()
           }
        
}
