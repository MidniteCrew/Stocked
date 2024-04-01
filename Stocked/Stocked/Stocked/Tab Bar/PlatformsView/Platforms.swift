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



extension ViewController: UITabBarControllerDelegate{
    
   
    public func setupPlatformsButton() {
            let platformsButton = UIButton(type: .system)
            platformsButton.setTitle("Platforms", for: .normal)
            platformsButton.addTarget(self, action: #selector(PlatformButtonTapped), for: .touchUpInside)
            // Layout your button as needed and add it to the view
            self.view.addSubview(platformsButton)
            // Set constraints or frame for platformsButton as required
        }
   
    // UITabBarControllerDelegate method
       func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
           // Check if the tab at index 1 is selected
           if tabBarController.selectedIndex == 0 {
               PlatformButtonTapped()
           }
       }
    
    
    @objc func PlatformButtonTapped() {
        
        // Haptic Feedback
        let generator = UIImpactFeedbackGenerator(style: .rigid)
        generator.prepare() // Preloads the necessary resources to reduce latency
        generator.impactOccurred()
        
        
        // Create and configure the platformViewController
        let platformViewController = UIViewController()
        platformViewController.view.backgroundColor = UIColor(red: 18/255, green: 18/255, blue: 18/255, alpha: 1.0)
        platformViewController.modalPresentationStyle = .overFullScreen
        
        // Retrieve the unique platforms with associated text views
        let platformsWithTextViews = Set(platformToTextViews.keys)
        
        // Sort the platforms alphabetically (optional)
        let uniquePlatformsWithTextViews = platformsWithTextViews.sorted()
        
        // Initialize the scroll view and add it to the platformViewController's view
           let scrollView = UIScrollView()
           scrollView.translatesAutoresizingMaskIntoConstraints = false
           scrollView.bounces = true
           scrollView.alwaysBounceVertical = true // Allow vertical bouncing 
           scrollView.contentInsetAdjustmentBehavior = .never // Adjust safe area insets behavior
           platformViewController.view.addSubview(scrollView)

           // Reset content inset
           scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

           // Set constraints for the scroll view to fill the platformViewController
           NSLayoutConstraint.activate([
               scrollView.topAnchor.constraint(equalTo: platformViewController.view.topAnchor),
               scrollView.bottomAnchor.constraint(equalTo: platformViewController.view.bottomAnchor),
               scrollView.leadingAnchor.constraint(equalTo: platformViewController.view.leadingAnchor),
               scrollView.trailingAnchor.constraint(equalTo: platformViewController.view.trailingAnchor)
           ])

        
        // Create a contentView that will hold all your buttons and labels, and add it to the scrollView
        let contentView = UIView()
        scrollView.addSubview(contentView)
        
        
        
        // Set contentView's constraints; important for UIScrollView to work correctly
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor) // Ensures contentView stretches across the scrollView's width
        ])
        
        var lastBottomAnchor = contentView.topAnchor // Start from the top of contentView
        
        
        
        var startingYPosition: CGFloat = 170.0
        
        for platform in uniquePlatformsWithTextViews {
            // Check if there are text views associated with this platform and if not, continue to the next iteration
            guard let associatedTextViews = platformToTextViews[platform], !associatedTextViews.isEmpty else {
                continue
            }
            
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
            platformButton.layer.cornerRadius = 10
            
            // Add each button to the contentView
            contentView.addSubview(platformButton)
            
            NSLayoutConstraint.activate([
                platformButton.topAnchor.constraint(equalTo: lastBottomAnchor, constant: 20), // Adjust spacing as needed
                platformButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                platformButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
                platformButton.heightAnchor.constraint(equalToConstant: 40) // Example height
            ])
            
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
            valueLabel.textColor = totalPositionValue > totalInitialInvestment ? UIColor(red: 103/255.0, green: 205/255.0, blue: 103/255.0, alpha: 1.0) : UIColor(red: 234/255.0, green: 85/255.0, blue: 69/255.0, alpha: 1.0)
            valueLabel.adjustsFontSizeToFitWidth = true
            
            // Add each button to the contentView
            contentView.addSubview(valueLabel)
            
            startingYPosition += buttonHeight + 20
            platformButtonStates[platformButton] = false
            
            // Update lastBottomAnchor to be the bottomAnchor of the last added component
            lastBottomAnchor = platformButton.bottomAnchor
        }
        
        // Set the bottom anchor of the last element to the contentView's bottom anchor
        // This step is crucial for UIScrollView to calculate its content size
        lastBottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -210).isActive = true
        
        
        // Use the custom transition delegate
        let transitionDelegate = CustomTransitionDelegate()
        platformViewController.transitioningDelegate = transitionDelegate
        platformViewController.modalPresentationStyle = .custom // Important to use custom presentation style
        
        // Present the platformViewController with the custom transition
        self.present(platformViewController, animated: true, completion: nil)
        
        // Setup swipe gesture recognizer for left swipes
        let swipeRightRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeRight(_:)))
        swipeRightRecognizer.direction = .left
        platformViewController.view.addGestureRecognizer(swipeRightRecognizer)
        
        //Exit button
        let backButton = UIButton(type: .system)
        if let arrowImage = UIImage(systemName: "arrow.turn.up.right") { // SF Symbol name for a curved arrow pointing right
            backButton.setImage(arrowImage, for: .normal)
        }
        backButton.tintColor = .systemBlue // Change the color if needed
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        
        // Positioning the button at the top right using Auto Layout
        backButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(backButton) // Add to contentView
        
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 95), // Position from contentView's top
            backButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 357), // Position from contentView's leading edge
            backButton.widthAnchor.constraint(equalToConstant: 40),
            backButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Platforms"
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .white
        contentView.addSubview(titleLabel) // Add to contentView
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 55), // Below backButton
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor), // Horizontally centered in contentView
            // These constraints ensure the label does not stretch beyond the contentView's bounds
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -20)
        ])
        
    }

    
    
    @objc func backButtonTapped() {
        // Haptic Feedback
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare() // Preloads the necessary resources to reduce latency
        generator.impactOccurred()

        // Animate the fade-out of the platformViewController
        if let platformViewController = self.presentedViewController {
            UIView.animate(withDuration: 0.15, animations: { // Reduced duration to 0.2 seconds
                // Fade out the view and move it to the left to simulate a swipe
                platformViewController.view.alpha = 0
                platformViewController.view.transform = CGAffineTransform(translationX: -self.view.frame.width, y: 0)
            }) { _ in
                // Dismiss the view controller after the animation completes
                self.dismiss(animated: false) {
                    // Switch to the tab at index 1 with an animation
                    if let tabBarController = self.tabBarController {
                        UIView.transition(with: tabBarController.view, duration: 0.2, options: .transitionCrossDissolve, animations: { // Reduced duration to 0.2 seconds
                            tabBarController.selectedIndex = 1
                        }, completion: nil)
                    }
                }
            }
        }
    }




    @objc func handleSwipeRight(_ gestureRecognizer: UISwipeGestureRecognizer) {
        if gestureRecognizer.state == .ended {
            // Call your method to handle the back action
            backButtonTapped()
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
                displayView.isUserInteractionEnabled = false // Disable user interaction
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

//For swiping animation from main menu to platforms page 
class CustomTransitionDelegate: NSObject, UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CustomAnimator()
    }
}

class CustomAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3 // Duration of the animation
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toViewController = transitionContext.viewController(forKey: .to) else { return }
        let containerView = transitionContext.containerView

        // Start with the toViewController off-screen to the left and fully transparent
        toViewController.view.frame = containerView.bounds.offsetBy(dx: -containerView.bounds.width, dy: 0)
        toViewController.view.alpha = 0

        containerView.addSubview(toViewController.view)

        // Animate the frame change and fade in
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            toViewController.view.frame = containerView.bounds // Slide in to final position
            toViewController.view.alpha = 1 // Fade in to fully opaque
        }) { finished in
            transitionContext.completeTransition(finished)
        }
    }
}
