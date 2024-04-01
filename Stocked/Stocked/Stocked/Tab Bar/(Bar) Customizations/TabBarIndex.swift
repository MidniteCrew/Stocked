//
//  TabBarIndex.swift
//  Stocked
//
//  Created by Gabriel Ungur on 2024-03-10.
//

import UIKit

class TabBarIndex: UITabBarController {
    
    @IBInspectable var initial_index: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedIndex = initial_index
        
    }
    
}
