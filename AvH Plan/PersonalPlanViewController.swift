//
//  PersonalPlanViewController.swift
//  AvH Plan
//
//  Created by Deniz Duezgoeren on 16.07.19.
//  Copyright © 2019 Deniz Duezgoeren. All rights reserved.
//

import UIKit

class PersonalPlanViewController: PlanViewController {
    
    let prefs = UserDefaults.standard
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let user = self.prefs.string(forKey: "username")
        var navigationBarTitle = ""
        if (user != nil && user != "") {
            if (user!.last == "x" || user!.last == "s" || user!.last == "z") {
                navigationBarTitle = "\(user!)\(NSLocalizedString("nosplan", comment: ""))"
            } else {
                navigationBarTitle = "\(user!)\(NSLocalizedString("splan", comment: ""))"
            }
        } else {
            navigationBarTitle = NSLocalizedString("your_plan", comment: "")
        }
        self.navigationController?.navigationBar.topItem?.title = navigationBarTitle
        self.prefs.set(0, forKey: "personalPlanCount")
        self.df.setTabBarBadge(for: self.tabBarController?.tabBar.items)
    }
    
    override func getViewType() -> String {
        return "personal"
    }
    
    override func getRefreshViewString() -> String {
        return NSLocalizedString("fetch_personal", comment: "")
    }
    
    override func getFromDatabase() -> [SubstModel] {
        return df.getPersonalFromDatabase()
    }

    override func getIndex() -> Int {
        return 1
    }
}
