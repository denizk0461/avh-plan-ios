//
//  CustomTabBarController.swift
//  AvH Plan
//
//  Created by Deniz Duezgoeren on 19.07.19.
//  Copyright © 2019 Deniz Duezgoeren. All rights reserved.
//

import UIKit

class CustomTabBarController: UITabBarController {
    
    let prefs = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()
        self.selectedIndex = prefs.integer(forKey: "default-plan")
    }
}
