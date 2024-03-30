//
//  SavingAndDeleting.swift
//  Stocked
//
//  Created by Gabriel Ungur on 2024-02-19.
//

import UIKit



let userDefaultsKey = "SavedStockEntries"  // Create a key for UserDefaults to uniquely identify the saved data

struct StockData {
    var stockName: String
    var initialInvestment: String
    var feesPaid: String
    var pricePerShare: String
    var stockPrice: Double
    var platform: String
}

var textViewToStockData: [UITextView: StockData] = [:]


extension ViewController{
    
    // Function to save the user's data to UserDefaults
    public func saveStockEntryToUserDefaults(stockName: String, initialInvestment: String, feesPaid: String, pricePerShare: String, stockPrice: Double, platform: String, index: Int) {
        let stockEntry: [String: Any] = [
            "stockName": stockName,
            "initialInvestment": initialInvestment,
            "feesPaid": feesPaid,
            "pricePerShare": pricePerShare,
            "stockPrice": stockPrice,
            "platform": platform,
            "index": index  // Include the order or index of the textView
        ]
        
        var savedEntries = UserDefaults.standard.array(forKey: userDefaultsKey) as? [[String: Any]] ?? []
        if index < savedEntries.count {
            savedEntries[index] = stockEntry  // Update existing entry
        } else {
            savedEntries.append(stockEntry)  // Add new entry
        }
        UserDefaults.standard.set(savedEntries, forKey: userDefaultsKey)
    }

    
    // Function to load saved data from UserDefaults
    public func loadSavedData() {
        if let savedEntries = UserDefaults.standard.array(forKey: userDefaultsKey) as? [[String: Any]] {
            let sortedEntries = savedEntries.sorted(by: { ($0["index"] as? Int ?? 0) < ($1["index"] as? Int ?? 0) })
            for entry in sortedEntries {
                if let stockName = entry["stockName"] as? String,
                   let initialInvestment = entry["initialInvestment"] as? String,
                   let feesPaid = entry["feesPaid"] as? String,
                   let pricePerShare = entry["pricePerShare"] as? String,
                   let stockPrice = entry["stockPrice"] as? Double,
                   let platform = entry["platform"] as? String {
                    createTextView(stockName: stockName, initialInvestment: initialInvestment, feesPaid: feesPaid, pricePerShare: pricePerShare, stockPrice: stockPrice, platform: platform)
                }
            }
        }
    }


    
    
    // Function to delete a stock entry and remove it from UserDefaults
    public func deleteStockEntry(_ entryIndex: Int) {
        var savedEntries = UserDefaults.standard.array(forKey: userDefaultsKey) as? [[String: Any]] ?? []
        
        // Ensure the index is within bounds
        guard entryIndex >= 0 && entryIndex < savedEntries.count else {
            return
        }
        
        // Remove the entry at the specified index
        savedEntries.remove(at: entryIndex)
        
        // Save the updated array to UserDefaults
        UserDefaults.standard.set(savedEntries, forKey: userDefaultsKey)
        UserDefaults.standard.synchronize()
    }
    
    public func repositionTextViews() {
        for textView in textViews {
            let xPosition = calculateXPositionForTextView()
            textView.frame.origin.x = xPosition
        }
    }
    
    @objc public func deleteSelectedTextViews() {
        //Haptic feedback for deleting
        let generator = UIImpactFeedbackGenerator(style: .rigid)
           generator.prepare() // Preparing the generator can reduce latency when triggering the feedback
           generator.impactOccurred()
        
        for textView in selectedTextViews {
            // Remove the textView from its associated platform array
            if let stockSymbol = textViewToStockSymbol[textView], let platform = findPlatformForStockSymbol(stockSymbol) {
                platformToTextViews[platform] = platformToTextViews[platform]?.filter { $0 != textView }
            }
        }
        isEditingMode = false
        updateTextViewsForEditingMode()
        editButton.setTitle("Edit", for: .normal)
        AddButton.isEnabled = true
        deleteButton.isHidden = true
        settingsButton.isHidden = false

        // Retrieve the current saved entries from UserDefaults
        var savedEntries = UserDefaults.standard.array(forKey: userDefaultsKey) as? [[String: Any]] ?? []

        for textView in selectedTextViews {
            // Remove the textView from the UI
            textView.removeFromSuperview()

            // Find the corresponding entry in savedEntries and remove it
            if let index = textViews.firstIndex(of: textView) {
                textViews.remove(at: index)
                savedEntries.remove(at: index)  // Assuming the order in textViews and savedEntries is synchronized
            }

            // Clean up any associated data with the textView
            selectionIndicators[textView]?.removeFromSuperview()
            selectionIndicators.removeValue(forKey: textView)
        }

        // Update UserDefaults with the modified entries
        UserDefaults.standard.set(savedEntries, forKey: userDefaultsKey)
        UserDefaults.standard.synchronize()

        // Clear the selected textViews and update UI accordingly
        selectedTextViews.removeAll()
        reorderTextViews()
        updateScrollViewContentSize()
       // updateTotalPositionValueLabelPosition()
        refreshStockData()
    }
    
    
    public func saveTextViewsOrder() {
        for (index, textView) in textViews.enumerated() {
            guard let stockData = textViewToStockData[textView] else { continue }
            
            saveStockEntryToUserDefaults(stockName: stockData.stockName, initialInvestment: stockData.initialInvestment, feesPaid: stockData.feesPaid, pricePerShare: stockData.pricePerShare, stockPrice: stockData.stockPrice, platform: stockData.platform, index: index)
        }
    }


}
