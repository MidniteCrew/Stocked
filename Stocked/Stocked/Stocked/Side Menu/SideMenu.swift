//
//  SideMenu.swift
//  Stocked
//
//  Created by Gabriel Ungur on 2024-02-19.
//

                                                        //ADD TAP RESPONSE ON THEME BUTTON. PLATFORM BUTTON HAS THIS 

import UIKit

//Button Colors
let lighterGray = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)


extension ViewController{
    
    @objc public func closeMenu() {
        // Haptic Feedback
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare() // Preloads the necessary resources to reduce latency
        generator.impactOccurred()
        
        
        UIView.animate(withDuration: 0.3) {
            self.menuView.frame.origin.x = -self.menuView.frame.width
        }
        
        // Hide the overlay view
        overlayView.isHidden = true
    }
    
    
    @objc func hideMenu() {
        UIView.animate(withDuration: 0.3) {
            self.menuView.frame.origin.x = -self.menuView.frame.width
        }
    }
    
    @objc func overlayTapped() {
        closeMenu()
    }
    
    
    //First button, PLATFORM
    public func setupPlatformButton() {
        let PlatformButton = UIButton(type: .system)
        PlatformButton.setTitle("Platforms", for: .normal)
        PlatformButton.addTarget(self, action: #selector(PlatformButtonTapped), for: .touchUpInside)

        // Match the width of the button to the menuView's width
        let buttonWidth = menuView.frame.width
        let buttonHeight: CGFloat = 30
        let buttonY = closeButton.frame.maxY + 20 // 20 points below the close button

        PlatformButton.frame = CGRect(x: 0, y: buttonY, width: buttonWidth, height: buttonHeight)

        // Set background color to white
        PlatformButton.backgroundColor = UIColor.systemGray5

        // Optional: Set other properties like title color, border, etc., if needed
        PlatformButton.setTitleColor(lighterGray, for: .normal) // Ensure the title is visible on white background
        //PlatformButton.layer.borderWidth = 1.0
        //PlatformButton.layer.borderColor = UIColor.darkGray.cgColor
        PlatformButton.layer.cornerRadius = 8.0
        
        // Set the font size to match the "Platforms" button
        PlatformButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)

        //Shadow
        PlatformButton.layer.shadowColor = UIColor.black.cgColor
        PlatformButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        PlatformButton.layer.shadowOpacity = 0.1
        PlatformButton.layer.shadowRadius = 4.0

        //Interaction animation
        PlatformButton.setBackgroundImage(UIImage(named: "HighlightedStateImage"), for: .highlighted)
        
        // Add to menu view
        menuView.addSubview(PlatformButton)
    }

    
    //Setup button: THEME 
    public func setupThemeButton() {
        let themeButton = UIButton(type: .custom)
        themeButton.setTitle("Theme", for: .normal)
        themeButton.addTarget(self, action: #selector(themeButtonTapped), for: .touchUpInside)
        
        // Adjust these values as needed
        let buttonWidth = menuView.frame.width
        let buttonHeight: CGFloat = 30
        let buttonX: CGFloat = 0  // Same horizontal position as Calculator button
        let buttonY = closeButton.frame.maxY + 60 // 20 points below the Calculator button
        
        themeButton.frame = CGRect(x: buttonX, y: buttonY, width: buttonWidth, height: buttonHeight)
        
        // Set the background color to pink
        themeButton.backgroundColor = UIColor.systemGray5  // Using a predefined system pink color
        themeButton.setTitleColor(lighterGray, for: .normal) // Set the title color to black
        
        // Set the font size to match the "Platforms" button
        themeButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)

        // Optional: Add border properties if needed
        //themeButton.layer.borderWidth = 1.0
        //themeButton.layer.borderColor = UIColor.darkGray.cgColor
        themeButton.layer.cornerRadius = 8.0
        
        //Shadow
        themeButton.layer.shadowColor = UIColor.black.cgColor
        themeButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        themeButton.layer.shadowOpacity = 0.1
        themeButton.layer.shadowRadius = 4.0

        //Interaction animation
        themeButton.setBackgroundImage(UIImage(named: "HighlightedStateImage"), for: .highlighted)
        
        // Add to menu view
        menuView.addSubview(themeButton)
        
    }
    
    
    
    // Setup button: LION
    public func setupLionButton() {
        let lionButton = UIButton(type: .custom)
        lionButton.setTitle("Lion", for: .normal)
        lionButton.addTarget(self, action: #selector(lionButtonTapped), for: .touchUpInside)
        
        // Adjust these values as needed
        let buttonWidth = menuView.frame.width
        let buttonHeight: CGFloat = 30
        let buttonX: CGFloat = 0  // Same horizontal position as other buttons
        let buttonY = closeButton.frame.maxY + 60 + 20 + 20// 20 points below the Theme button
        
        lionButton.frame = CGRect(x: buttonX, y: buttonY, width: buttonWidth, height: buttonHeight)
        
        // Set the background color to match the theme of your app
        lionButton.backgroundColor = UIColor.systemGray5  // Using a predefined system gray color
        lionButton.setTitleColor(lighterGray, for: .normal) // Set the title color to match your app's theme
        
        // Set the font size to match the other buttons
        lionButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)

        // Optional: Add border properties if needed
        lionButton.layer.cornerRadius = 8.0
        
        // Shadow
        lionButton.layer.shadowColor = UIColor.black.cgColor
        lionButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        lionButton.layer.shadowOpacity = 0.1
        lionButton.layer.shadowRadius = 4.0

        // Interaction animation
        lionButton.setBackgroundImage(UIImage(named: "HighlightedStateImage"), for: .highlighted)
        
        // Add to menu view
        menuView.addSubview(lionButton)
    }
   
    
}
