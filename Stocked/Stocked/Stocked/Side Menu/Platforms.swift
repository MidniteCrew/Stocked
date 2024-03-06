//
//  Platforms.swift
//  Stocked
//
//  Created by Gabriel Ungur on 2024-02-19.
//

import UIKit


var platformButtonToValueLabel: [UIButton: UILabel] = [:]
// Add a dictionary to track the state of each platform button
var platformButtonStates: [UIButton: Bool] = [:]



extension ViewController{
    
   
    public func setupPlatformsButton() {
            let platformsButton = UIButton(type: .system)
            platformsButton.setTitle("Platforms", for: .normal)
            platformsButton.addTarget(self, action: #selector(PlatformButtonTapped), for: .touchUpInside)
            // Layout your button as needed and add it to the view
            self.view.addSubview(platformsButton)
            // Set constraints or frame for platformsButton as required
        }


    @objc func PlatformButtonTapped() {
        // Haptic Feedback
        let generator = UIImpactFeedbackGenerator(style: .rigid)
        generator.prepare() // Preloads the necessary resources to reduce latency
        generator.impactOccurred()
        
        
        // Create and configure the platformViewController
        let platformViewController = UIViewController()
        platformViewController.view.backgroundColor = .systemBackground
        platformViewController.modalPresentationStyle = .overFullScreen

        let platformsWithTextViews = platforms.filter { platform in
            if let textViewsForPlatform = platformToTextViews[platform], !textViewsForPlatform.isEmpty {
                return true
            }
            return false
        }

        let uniquePlatformsWithTextViews = Array(Set(platformsWithTextViews))

        var startingYPosition: CGFloat = 170.0

        for platform in uniquePlatformsWithTextViews {
            let platformButton = UIButton(type: .system)
            platformButton.setTitle("→ \(platform)", for: .normal)
            platformButton.addTarget(self, action: #selector(platformButtonAction(_:)), for: .touchUpInside)

            let buttonWidth: CGFloat = platformViewController.view.frame.width * 0.8
            let buttonHeight: CGFloat = 40
            let buttonXPosition: CGFloat = (platformViewController.view.frame.width - buttonWidth) / 2
            platformButton.frame = CGRect(x: buttonXPosition, y: startingYPosition, width: buttonWidth, height: buttonHeight)

            platformButton.contentHorizontalAlignment = .left
            platformButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
            platformButton.backgroundColor = UIColor(red: 60/255, green: 60/255, blue: 60/255, alpha: 1.0)
            platformButton.setTitleColor(.white, for: .normal)
            platformButton.layer.cornerRadius = 5

            platformViewController.view.addSubview(platformButton)

            var totalPositionValue: Double = 0.0
            var totalInitialInvestment: Double = 0.0
            platformToTextViews[platform]?.forEach { textView in
                totalPositionValue += extractPositionValue(from: textView)
                totalInitialInvestment += extractInitialInvestment(from: textView)
            }

            // Calculate the percentage change
            let percentageChange = ((totalPositionValue - totalInitialInvestment) / totalInitialInvestment) * 100

            // NumberFormatter for formatting the values
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            numberFormatter.groupingSeparator = ","
            numberFormatter.maximumFractionDigits = 2

            // Create a label to display the total position value and percentage change
            let valueLabel = UILabel()
            platformButtonToValueLabel[platformButton] = valueLabel

            // Format totalPositionValue and percentageChange
            let formattedPositionValue = numberFormatter.string(from: NSNumber(value: totalPositionValue)) ?? "\(totalPositionValue)"
            var formattedPercentageChange: String

            
            //Adding "+" or "-" 
            if percentageChange > 0 {
                formattedPercentageChange = "+\(numberFormatter.string(from: NSNumber(value: percentageChange)) ?? "\(percentageChange)")"
            } else if percentageChange < 0 {
                formattedPercentageChange = "\(numberFormatter.string(from: NSNumber(value: percentageChange)) ?? "\(percentageChange)")"
            } else {
                formattedPercentageChange = "\(percentageChange)"
            }
            
            
            let formattedText = "$\(formattedPositionValue) (\(formattedPercentageChange)%)"
            valueLabel.text = formattedText
            valueLabel.textAlignment = .right
            valueLabel.frame = CGRect(x: buttonXPosition + buttonWidth - 150, y: startingYPosition, width: 150, height: buttonHeight)
            valueLabel.backgroundColor = .clear
            valueLabel.textColor = totalPositionValue > totalInitialInvestment ? .green : .red
            valueLabel.adjustsFontSizeToFitWidth = true

            platformViewController.view.addSubview(valueLabel)

            startingYPosition += buttonHeight + 20
            platformButtonStates[platformButton] = false
        }

        platformViewController.view.alpha = 0

        self.present(platformViewController, animated: false) {
            UIView.animate(withDuration: 0.35) {
                platformViewController.view.alpha = 1
            }
        }

        let backButton = UIButton(type: .system)
        backButton.setTitle("Exit", for: .normal)
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        backButton.frame = CGRect(x: 20, y: 80, width: 80, height: 90)
        platformViewController.view.addSubview(backButton)

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Platforms"
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .white
        platformViewController.view.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: platformViewController.view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: platformViewController.view.centerXAnchor),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: platformViewController.view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: platformViewController.view.trailingAnchor, constant: -20)
        ])
    }

    
    
    @objc func backButtonTapped() {
        // Haptic Feedback
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare() // Preloads the necessary resources to reduce latency
        generator.impactOccurred()
    
        // Animate the fade-out of the platformViewController
        if let platformViewController = self.presentedViewController {
            UIView.animate(withDuration: 0.35, animations: {
                // Fade out the view
                platformViewController.view.alpha = 0
            }) { _ in
                // Dismiss the view controller after the animation completes
                self.dismiss(animated: false) {
                    // Optionally, trigger any additional logic to reset the state or UI of your main view
                    // This might involve resetting button states, layouts, or other UI elements affected by the presentation of the platformViewController
                }
            }
        }
    }

    
    

    // Call this method when you want to dismiss the platforms page and restore interaction to the main view
    func dismissPlatformViewController() {
        self.dismiss(animated: true) {
            // Re-enable user interactions if they were disabled
            self.settingsButton.isUserInteractionEnabled = true
            self.AddButton.isUserInteractionEnabled = true
            self.editButton.isUserInteractionEnabled = true

            // Ensure any overlay views are hidden or removed
            self.overlayView.isHidden = true

            // Add any additional logic needed to restore the state of your main view
        }
    }

    // Example of how to dismiss from within the platformViewController
    @objc func closePlatformView() {
        dismissPlatformViewController()
    }
    
    @objc func platformButtonAction(_ sender: UIButton) {
            let feedbackGenerator = UISelectionFeedbackGenerator()
            feedbackGenerator.prepare()
            feedbackGenerator.selectionChanged()
        
        // Ensure we have a button title
           guard let buttonTitle = sender.title(for: .normal) else { return }

           // Directly create a String from the Substring obtained by dropping the first two characters
           let platformName = String(buttonTitle.dropFirst(2))

           // Toggle the button's state and update the title
           if let isExpanded = platformButtonStates[sender] {
               let newTitle = isExpanded ? "→ \(platformName)" : "↓ \(platformName)"
               sender.setTitle(newTitle, for: .normal)
               platformButtonStates[sender] = !isExpanded
           }


        // Proceed based on the updated state
        if let isExpanded = platformButtonStates[sender], isExpanded {
            // The button is now in the expanded state, so show the associated text views
            guard let associatedTextViews = platformToTextViews[platformName], !associatedTextViews.isEmpty else { return }

            var yOffset = sender.frame.maxY + 10

            for originalTextView in associatedTextViews {
                let displayView = UITextView(frame: CGRect(x: sender.frame.minX, y: yOffset, width: sender.frame.width, height: originalTextView.frame.height))

                // Copy the attributed text and other properties
                displayView.attributedText = originalTextView.attributedText
                displayView.backgroundColor = originalTextView.backgroundColor
                displayView.layer.cornerRadius = originalTextView.layer.cornerRadius
                displayView.clipsToBounds = true
                displayView.isEditable = false
                displayView.isSelectable = false
                displayView.tag = 999 // Tag for easy identification
                displayView.accessibilityLabel = "\(platformName)-\(originalTextView.text ?? "")"

                sender.superview?.addSubview(displayView)

                yOffset += displayView.frame.height + 10
            }

            let adjustmentHeight = yOffset - (sender.frame.maxY + 10)
            adjustButtonPositions(startingFrom: sender, inSuperview: sender.superview, adjustmentHeight: adjustmentHeight)
        } else {
            // The button is now in the collapsed state, so hide the associated text views
            if let existingViews = sender.superview?.subviews.filter({ $0.tag == 999 && $0.accessibilityLabel?.contains(platformName) ?? false }) {
                var adjustmentHeight: CGFloat = 0

                existingViews.forEach {
                    adjustmentHeight += $0.frame.height + 10 // Calculate total height of views to be removed
                    $0.removeFromSuperview()
                }

                adjustButtonPositions(startingFrom: sender, inSuperview: sender.superview, adjustmentHeight: -adjustmentHeight)
            }
        }
    }



    // Helper method to adjust the positions of platform buttons
    public func adjustButtonPositions(startingFrom button: UIButton, inSuperview superview: UIView?, adjustmentHeight: CGFloat) {
        guard let subviews = superview?.subviews else { return }

        // Filter out buttons that are below the starting button
        let buttonsBelow = subviews.filter { $0 is UIButton && $0.frame.origin.y > button.frame.origin.y } as? [UIButton] ?? []

        for btn in buttonsBelow {
            // Calculate the new Y position for the button
            let newButtonY = btn.frame.origin.y + adjustmentHeight

            // Move the button to its new position
            UIView.animate(withDuration: 0.2) {
                btn.frame.origin.y = newButtonY
            }

            // Update the position of the associated value label
            if let valueLabel = platformButtonToValueLabel[btn] {
                UIView.animate(withDuration: 0.2) {
                    // Align the top of the label with the top of the button
                    var valueLabelFrame = valueLabel.frame
                    valueLabelFrame.origin.y = newButtonY
                    valueLabel.frame = valueLabelFrame
                }
            }

            // Check if the button has associated text views displayed (tagged as 999)
            if let associatedTextViews = superview?.subviews.filter({ $0.tag == 999 && $0.accessibilityLabel?.contains(btn.title(for: .normal)?.dropFirst(2) ?? "") ?? false }) {
                // The starting Y position for the first text view should be just below the button
                var textViewYOffset = newButtonY + btn.frame.height + 10 // Adjust the spacing as needed

                for textView in associatedTextViews.sorted(by: { $0.frame.origin.y < $1.frame.origin.y }) {
                    UIView.animate(withDuration: 0.2) {
                        // Move each associated text view to its new position below the button
                        textView.frame.origin.y = textViewYOffset
                        textViewYOffset += textView.frame.height + 10 // Prepare yOffset for the next text view, adjusting the spacing as needed
                    }
                }
            }
        }
    }



   
     
    // Function to add a text view to the mapping
    func addTextView(_ textView: UITextView, forPlatform platform: String) {
        if platformToTextViews[platform] != nil {
            platformToTextViews[platform]?.append(textView)
        } else {
            platformToTextViews[platform] = [textView]
        }
    }
    
    
    public func findPlatformForStockSymbol(_ stockSymbol: String) -> String? {
        for (platform, textViews) in platformToTextViews {
            for textView in textViews {
                if let symbol = textViewToStockSymbol[textView], symbol == stockSymbol {
                    return platform
                }
            }
        }
        return nil
    }
    
    
}
