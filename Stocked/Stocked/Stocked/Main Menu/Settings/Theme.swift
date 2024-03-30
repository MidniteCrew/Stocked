//
//  Theme.swift
//  Stocked
//
//  Created by Gabriel Ungur on 2024-02-17.
//

import UIKit

public var closeButton: UIButton!
let themeColors: [UIColor] = [.red, .green, .blue, .systemPink] // Add more colors as needed


extension ViewController{
    
    
   
    
    @objc public func themeButtonTapped() {
        // Haptic Feedback
        let generator = UIImpactFeedbackGenerator(style: .rigid)
        generator.prepare()  // Preloads the necessary resources to reduce latency
        generator.impactOccurred()

        closeMenu()  // Function to close any open menu, assuming it's already implemented

        // Hide other UI elements
        settingsButton.isHidden = true
        AddButton.isHidden = true
        editButton.isHidden = true

        // Calculate the xOffset for alignment between the screen's edge and the first textView's left edge
        guard let firstTextView = textViews.first else { return }
        let xOffset: CGFloat = (firstTextView.frame.origin.x) / 2  // Center point for the circles

        // Align the center of the exit button's text with the color circles' X-axis
        exitButton.center.x = xOffset

        // Align the exit button's Y position with the totalPositionValueLabel's Y position
        exitButton.frame.origin.y = 150

        exitButton.isHidden = false  // Show the exit button

        displayColorCircles()  // Function to display the color selection circles, assuming it's already implemented to use the same xOffset
    }

    
 func toggleSettingsButtonToExit() {
     settingsButton.setTitle("Exit", for: .normal)
     settingsButton.removeTarget(nil, action: nil, for: .allEvents) // Remove existing actions
     settingsButton.addTarget(self, action: #selector(exitThemeMode), for: .touchUpInside)
 }
    
    

 @objc func exitThemeMode() {
     
     // Haptic Feedback
     let generator = UIImpactFeedbackGenerator(style: .rigid)
     generator.prepare()  // Preloads the necessary resources to reduce latency
     generator.impactOccurred()
     
     // Hide the Exit button and show the other buttons again
     exitButton.isHidden = true
     settingsButton.isHidden = false
     AddButton.isHidden = false
     editButton.isHidden = false

     // Remove color circles from the view
     scrollView.subviews.filter { $0.layer.cornerRadius == 15 }.forEach { $0.removeFromSuperview() }

     // Revert any theme-related UI changes
 }

    
    
 func showColorSelectionCircles() {
     let colors: [UIColor] = [.red, .green, .blue, .systemPink] // Add more colors as needed
     let circleDiameter: CGFloat = 30
     let spacing: CGFloat = 10
     var offsetX: CGFloat = settingsButton.frame.maxX + spacing

     for color in colors {
         let circleView = UIView(frame: CGRect(x: offsetX, y: settingsButton.frame.minY, width: circleDiameter, height: circleDiameter))
         circleView.backgroundColor = color
         circleView.layer.cornerRadius = circleDiameter / 2
         self.view.addSubview(circleView)

         offsetX += circleDiameter + spacing
     }
 }

    
    
    
    func displayColorCircles() {
        guard let firstTextView = textViews.first else { return }
        let circleDiameter: CGFloat = 30
        let spacing: CGFloat = 10
        let xOffset: CGFloat = (firstTextView.frame.origin.x) / 2  // Center point for the circles
        var yOffset: CGFloat = firstTextView.frame.origin.y
        
        themeColors.forEach { color in
            let circleView = UIView(frame: CGRect(x: xOffset - circleDiameter / 2, y: yOffset, width: circleDiameter, height: circleDiameter))
            circleView.backgroundColor = color
            circleView.layer.cornerRadius = circleDiameter / 2
            circleView.layer.masksToBounds = true
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(colorCircleTapped(_:)))
            circleView.addGestureRecognizer(tapGesture)
            circleView.isUserInteractionEnabled = true
            
            scrollView.addSubview(circleView)
            
            yOffset += circleDiameter + spacing  // Move down for the next circle
        }
    }


    
 @objc func colorCircleTapped(_ gesture: UITapGestureRecognizer) {
     
     let feedbackGenerator = UISelectionFeedbackGenerator()
     feedbackGenerator.prepare()
     feedbackGenerator.selectionChanged()
     
     guard let circleView = gesture.view else { return }

     // Use the circleView's background color as the selected theme color
     let selectedColor = circleView.backgroundColor ?? .clear

     // Apply the selected color to your UI elements, e.g., background color of text views
     textViews.forEach { textView in
         textView.backgroundColor = selectedColor
     }
 }


}


