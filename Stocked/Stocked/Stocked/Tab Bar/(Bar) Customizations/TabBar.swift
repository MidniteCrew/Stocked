//
//  TabBar.swift
//  Stocked
//
//  Created by Gabriel Ungur on 2024-03-03.
//
import UIKit

class TabBar: UITabBar {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customizeCornerRadius(radius: 0) // Adjust the radius value as needed
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        customizeCornerRadius(radius: 0) // Adjust the radius value as needed
    }

    func customizeCornerRadius(radius: CGFloat) {
        self.clipsToBounds = true
        self.layer.cornerRadius = radius
        // Optional: Add these lines if you want the tab bar to have a shadow.
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        self.layer.shadowRadius = 5
        self.layer.shadowOpacity = 0.5
    }
    
    
    
    
}
