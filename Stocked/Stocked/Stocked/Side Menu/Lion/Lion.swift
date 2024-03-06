//
//  Lion.swift
//  Stocked
//
//  Created by Gabriel Ungur on 2024-03-01.
//

import Foundation
import UIKit

extension ViewController{
    
    
    @objc func lionButtonTapped() {
        // Present a new view or view controller
        presentLionView()
    }

    func presentLionView() {
        let lionViewController = LionViewController() // Assuming you have a LionViewController
        lionViewController.modalPresentationStyle = .fullScreen // or another presentation style you prefer
        present(lionViewController, animated: true, completion: nil)
    }

  
    
}
