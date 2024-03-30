//
//  FetchingInvestmentDetails.swift
//  Stocked
//
//  Created by Gabriel Ungur on 2024-02-19.
//

import UIKit


let stockSymbolMapping: [String: String] = [
    "Apple Inc": "AAPL",
    "Microsoft Corporation": "MSFT",
    "Amazon.com Inc": "AMZN",
    "Alphabet Inc": "GOOGL",
    "Facebook, Inc": "FB",
    "Tesla, Inc": "TSLA",
    "Berkshire Hathaway Inc": "BRK.A",
    "Johnson & Johnson": "JNJ",
    "Visa Inc": "V",
    "Walmart Inc": "WMT",
    "Coca-Cola Co": "KO",
    "Marathon Digital Holdings Inc": "MARA",
    "Hut 8 Corp": "HUT",
    "Bitfarms Ltd": "BITF",
    // ... additional mappings ...
]

// Sample format for the "Stock Symbol" line in the text view
let stockInfo = """
Stock Symbol: AAPL
Initial Investment: $1000
Quantity of Shares: 10 shares
Market Price: $150.00 USD
Position Value: $1500.00 CAD
Profit/Loss: +$500.00 CAD (+50.00%)
"""

// Mapping for cryptocurrency symbols to full names
let cryptocurrencyFullNameMapping: [String: String] = [
    "BTC": "Bitcoin",
    "ETH": "Ethereum",
    "XRP": "Ripple",
    // Add more mappings as needed
]

// Reverse mapping from full names to symbols
let cryptocurrencySymbolMapping = Dictionary(uniqueKeysWithValues: cryptocurrencyFullNameMapping.map { ($1, $0) })



extension ViewController{
    
    func fetchStockPrice(for symbol: String, completion: @escaping (Double?) -> Void) {
        let finnhubApiKey = "cmacv81r01qid8gedk60cmacv81r01qid8gedk6g"
        let coinbaseApiKey = "57ca4572-298a-4b92-ba8d-ef6214b76ab1"
        
        var adjustedSymbol = symbol
           
        if adjustedSymbol.hasSuffix(".TO") {
               adjustedSymbol = String(adjustedSymbol.dropLast(3))
           }

        let isCrypto = isCryptocurrency(symbol: adjustedSymbol)
        let urlString: String
        
        
        if isCrypto {
            urlString = "https://api.coinbase.com/v2/prices/\(adjustedSymbol)-USD/spot"
        } else {
            urlString = "https://finnhub.io/api/v1/quote?symbol=\(adjustedSymbol)&token=\(finnhubApiKey)"
        }
        
      
        guard let url = URL(string: urlString) else {
            print("Invalid URL for symbol: \(adjustedSymbol)")
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching stock data for \(adjustedSymbol): \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
                return
            }
            
            if isCrypto {
                // Parse response from Coinbase
                do {
                    let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
                    if let dataDict = (jsonObject as? [String: Any])?["data"] as? [String: Any],
                       let price = dataDict["amount"] as? String,
                       let priceDouble = Double(price) {
                        print("Fetched price for \(adjustedSymbol): \(priceDouble)")
                        completion(priceDouble)
                    } else {
                        print("Error parsing Coinbase data for \(adjustedSymbol)")
                        completion(nil)
                    }
                } catch {
                    print("Error parsing JSON from Coinbase for \(adjustedSymbol): \(error.localizedDescription)")
                    completion(nil)
                }
            } else {
                // Parse response from Finnhub for stocks
                do {
                    let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
                    if let dataDict = jsonObject as? [String: Any],
                       let currentPrice = dataDict["c"] as? Double, currentPrice != 0 {
                        print("Fetched price for \(adjustedSymbol): \(currentPrice)")
                        completion(currentPrice)
                    } else {
                        print("Error or Zero value in Finnhub data for \(adjustedSymbol). Response: \(String(data: data, encoding: .utf8) ?? "N/A")")
                        completion(nil)
                    }
                } catch {
                    print("Error parsing JSON from Finnhub for \(adjustedSymbol): \(error.localizedDescription)")
                    completion(nil)
                }
            }
        }.resume()
    }
    
    func isCryptocurrency(symbol: String) -> Bool {
        // List of known cryptocurrency symbols
        let cryptoSymbols = ["BTC", "ETH", "XRP", "LTC", "BCH", "DOGE", "ADA", "SOL", "DOT", "UNI", "LINK", "BNB", "USDT", "USDC", "XLM", "TRX", "EOS", "NEO", "XTZ", "MIOTA"]
        
        return cryptoSymbols.contains(symbol.uppercased())
    }
    
    func fetchStockDetails(for symbol: String, initialInvestment: String, feesPaid: String, pricePerShare: String, platform: String) {
        let detailsURLString = "https://finnhub.io/api/v1/stock/profile2?symbol=\(symbol)&token=cmacv81r01qid8gedk60cmacv81r01qid8gedk6g"
        
        guard let detailsURL = URL(string: detailsURLString) else {
            print("Invalid URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: detailsURL) { [weak self] data, response, error in
            guard let self = self, let data = data, error == nil else {
                DispatchQueue.main.async {
                    self?.fetchStockDetailsFromCoinbase(for: symbol, initialInvestment: initialInvestment, feesPaid: feesPaid, pricePerShare: pricePerShare, platform: platform)
                }
                return
            }
            
            do {
                if let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let companyName = jsonObject["name"] as? String,
                   let stockSymbol = jsonObject["ticker"] as? String {
                    
                    // Fetch the stock price using the symbol
                    self.fetchStockPrice(for: stockSymbol) { price in
                        DispatchQueue.main.async {
                            guard let price = price else {
                                self.showStockNotFoundAlert()
                                return
                            }

                            // Assuming textViews represent your stock entries and their order
                            let newIndex = self.textViews.count

                            self.createTextView(stockName: companyName, initialInvestment: initialInvestment, feesPaid: feesPaid, pricePerShare: pricePerShare, stockPrice: price, platform: platform)

                            // Save the created entry to UserDefaults, including the new index
                            self.saveStockEntryToUserDefaults(stockName: companyName, initialInvestment: initialInvestment, feesPaid: feesPaid, pricePerShare: pricePerShare, stockPrice: price, platform: platform, index: newIndex)
                        }

                    }
                } else {
                    DispatchQueue.main.async {
                        self.fetchStockDetailsFromCoinbase(for: symbol, initialInvestment: initialInvestment, feesPaid: feesPaid, pricePerShare: pricePerShare, platform: platform)
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.fetchStockDetailsFromCoinbase(for: symbol, initialInvestment: initialInvestment, feesPaid: feesPaid, pricePerShare: pricePerShare, platform: platform)
                }
            }
        }
        task.resume()
    }
    
    func showStockNotFoundAlert() {
        let alert = UIAlertController(title: "Error", message: "The stock was not found!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }
    
    // Modify the fetchStockDetailsFromCoinbase function
    func fetchStockDetailsFromCoinbase(for symbol: String, initialInvestment: String, feesPaid: String, pricePerShare: String, platform: String) {
        let urlString = "https://api.coinbase.com/v2/prices/\(symbol)-USD/spot"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL for Coinbase API")
            return
        }
        
        var request = URLRequest(url: url)
        request.addValue("57ca4572-298a-4b92-ba8d-ef6214b76ab1", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let strongSelf = self else {
                print("ViewController is nil")
                return
            }
            
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    strongSelf.showStockNotFoundAlert()
                }
                return
            }
            
            do {
                if let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let dataDict = jsonObject["data"] as? [String: Any],
                   let price = dataDict["amount"] as? String,
                   let priceDouble = Double(price) {
                    
                    let cryptocurrencyName = cryptocurrencyFullNameMapping[symbol.uppercased()] ?? symbol.uppercased()
                    
                    DispatchQueue.main.async {
                        // Use the full name of the cryptocurrency instead of its symbol
                        strongSelf.createTextView(stockName: cryptocurrencyName, initialInvestment: initialInvestment, feesPaid: feesPaid, pricePerShare: pricePerShare, stockPrice: priceDouble, platform: platform)
                        
                        // Determine the new index for the entry
                        let newIndex = strongSelf.textViews.count
                        
                        // Save the created entry to UserDefaults, including the new index
                        strongSelf.saveStockEntryToUserDefaults(stockName: cryptocurrencyName, initialInvestment: initialInvestment, feesPaid: feesPaid, pricePerShare: pricePerShare, stockPrice: priceDouble, platform: platform, index: newIndex)
                    }

                } else {
                    DispatchQueue.main.async {
                        strongSelf.showStockNotFoundAlert()
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    strongSelf.showStockNotFoundAlert()
                }
            }
        }.resume()
    }
    
    public func refreshStockData(silent: Bool = false) {
        let dispatchGroup = DispatchGroup()

        if !silent {
            DispatchQueue.main.async {
                self.refreshControl.beginRefreshing()
                self.scrollView.setContentOffset(CGPoint(x: 0, y: -self.refreshControl.frame.size.height), animated: true)
            }
        }

        for (textView, companyName) in textViewToStockSymbol {
            let stockSymbol: String
            if let symbol = cryptocurrencySymbolMapping[companyName] {
                stockSymbol = symbol
            } else {
                stockSymbol = stockSymbolMapping[companyName] ?? companyName
            }

            dispatchGroup.enter()
            fetchStockPrice(for: stockSymbol) { [weak self] newPrice in
                defer { dispatchGroup.leave() }

                DispatchQueue.main.async {
                    guard let newPrice = newPrice else {
                        print("Failed to fetch new price for \(stockSymbol)")
                        return
                    }

                    self?.updateTextView(textView, withNewPrice: newPrice)
                }
            }
        }

        dispatchGroup.notify(queue: .main) {
            if !silent {
                self.refreshControl.endRefreshing()
            }
        }
    }


    
    @objc public func refreshStockData(_ sender: UIRefreshControl) {
        refreshStockData()
    }
    
    func getStockSymbol(for companyName: String) -> String {
        return stockSymbolMapping[companyName] ?? companyName
    }
    
    public func updateTextView(_ textView: UITextView, withNewPrice newPrice: Double) {
        guard let attributedText = textView.attributedText.mutableCopy() as? NSMutableAttributedString else {
            return
        }
        
        var initialInvestment: Double?
        var quantityOfShares: Double?
        
        // Extract values from the existing content
        let text = attributedText.string
        let lines = text.components(separatedBy: .newlines)
        
        for line in lines {
            if line.starts(with: "Initial Investment:") {
                // Remove commas before converting to Double
                let investmentString = line.split(separator: " ")[2].replacingOccurrences(of: ",", with: "")
                initialInvestment = Double(investmentString)
            } else if line.starts(with: "Quantity of Shares:") {
                // Extract the quantity string and remove commas before converting to Double
                let quantityString = line.split(separator: " ")[3].replacingOccurrences(of: ",", with: "")
                quantityOfShares = Double(quantityString)
            }
        }

        
        guard let investment = initialInvestment, let quantity = quantityOfShares else {
            print("Unable to extract investment data from the textView")
            return
        }
        
        // Recalculate Position Value, Profit/Loss, and Profit/Loss Percentage
        let positionValue = quantity * newPrice
        let profitOrLoss = positionValue - investment
        let profitOrLossPercentage = (profitOrLoss / investment) * 100
        
        // Update specific sections
        updateAttributedText(attributedText, with: newPrice, forKey: "Market Price:")
        updateAttributedText(attributedText, with: positionValue, forKey: "Position Value:")
        updateAttributedTextForProfitLoss(attributedText, profitOrLoss: profitOrLoss, profitOrLossPercentage: profitOrLossPercentage)
        
        // Apply the updated attributed text to the textView
        textView.attributedText = attributedText
        
        self.updateTotalPositionValueAndProfitLossPercentage() // New line to update the total
    }
    
    public func updateAttributedText(_ attributedText: NSMutableAttributedString, with newValue: Double, forKey key: String) {
        let text = attributedText.string

        // Configure the number formatter
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal  // Use the decimal style
        numberFormatter.groupingSeparator = "," // Use comma as the grouping separator
        numberFormatter.groupingSize = 3        // Group digits by thousands
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.maximumFractionDigits = 2

        // Format the new value using the number formatter
        guard let formattedValueString = numberFormatter.string(from: NSNumber(value: newValue)) else {
            print("Failed to format number")
            return
        }

        if let range = text.range(of: "\(key) .*", options: .regularExpression) {
            let newString = "\(key) \(formattedValueString)"
            
            let fullRange = NSRange(range, in: text)
            attributedText.replaceCharacters(in: fullRange, with: newString)

            // Find the start index of the numeric value
            let numericValueStartIndex = text.distance(from: text.startIndex, to: range.lowerBound) + key.count + 1 // +1 for the space after the colon

            // Calculate the length of the numeric value
            let numericValueLength = formattedValueString.count

            // Create a range that covers only the numeric value
            let valueRange = NSRange(location: numericValueStartIndex, length: numericValueLength)

            // Apply the white color to just the numeric value
            attributedText.addAttribute(.foregroundColor, value: UIColor.white, range: valueRange)
        }
    }


    
    public func updateAttributedTextForProfitLoss(_ attributedText: NSMutableAttributedString, profitOrLoss: Double, profitOrLossPercentage: Double) {
        let text = attributedText.string
        if let range = text.range(of: "Profit/Loss: .*", options: .regularExpression) {
            // Configure the number formatter for profit/loss values
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            numberFormatter.groupingSeparator = "," // Use comma as the grouping separator
            numberFormatter.groupingSize = 3
            numberFormatter.minimumFractionDigits = 2
            numberFormatter.maximumFractionDigits = 2

            // Format the profit/loss value
            guard let formattedProfitOrLoss = numberFormatter.string(from: NSNumber(value: profitOrLoss)) else {
                print("Failed to format profit/loss number")
                return
            }

            // Format the profit/loss percentage
            guard let formattedPercentage = numberFormatter.string(from: NSNumber(value: profitOrLossPercentage)) else {
                print("Failed to format profit/loss percentage")
                return
            }

            let sign = profitOrLoss >= 0 ? "+" : ""
            let percentageSign = profitOrLossPercentage >= 0 ? "+" : "" // Explicitly add "+" sign for positive percentages
            let updatedProfitLossString = "\(sign)\(formattedProfitOrLoss) USD (\(percentageSign)\(formattedPercentage)%)"

            // Calculate the range to replace with the formatted profit/loss string
            let numericValueStartIndex = text.distance(from: text.startIndex, to: range.lowerBound) + "Profit/Loss: ".count
            let numericValueLength = text[range].count - "Profit/Loss: ".count
            let numericValueRange = NSRange(location: numericValueStartIndex, length: numericValueLength)

            // Replace the old profit/loss string with the new formatted one
            attributedText.replaceCharacters(in: numericValueRange, with: updatedProfitLossString)

            // Update the color based on profit or loss
            let profitOrLossColor: UIColor = profitOrLoss >= 0 ? .green : .red
            attributedText.addAttribute(.foregroundColor, value: profitOrLossColor, range: NSRange(location: numericValueStartIndex, length: updatedProfitLossString.count))
        }
    }

    
    
}
