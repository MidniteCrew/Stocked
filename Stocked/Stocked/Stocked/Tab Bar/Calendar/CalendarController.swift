//
//  CalendarViewController.swift
//  Stocked
//
//  Created by Gabriel Ungur on 2024-03-10.
//

import UIKit

class CalendarController: UIViewController {
    
    // Properties to hold analytics data or references to UI elements
    let comingSoonLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Perform any additional setup after loading the view.
        setupUI()
    }

    func setupUI() {
        // Configure UI elements such as labels, buttons, charts, etc.
        comingSoonLabel.text = "Coming Soon..."
        comingSoonLabel.textAlignment = .center
        comingSoonLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        comingSoonLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(comingSoonLabel)
        
        // Set up constraints to center the label in the view
        NSLayoutConstraint.activate([
            comingSoonLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            comingSoonLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }


}
