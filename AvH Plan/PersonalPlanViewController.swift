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
    
    @IBAction func toolbarButtonCustomise(_ sender: UIBarButtonItem) {
//        let alert = UIAlertController(title: NSLocalizedString("customize_alert_title", comment: ""), message: nil, preferredStyle: .alert)
//        alert.addTextField { (name) in
//            name.text = self.prefs.string(forKey: "username")
//            name.placeholder = NSLocalizedString("name", comment: "")
//        }
//        alert.addTextField { (classes) in
//            classes.text = self.prefs.string(forKey: "classes")
//            classes.placeholder = NSLocalizedString("classes", comment: "")
//        }
//        alert.addTextField { (courses) in
//            courses.text = self.prefs.string(forKey: "courses")
//            courses.placeholder = NSLocalizedString("courses", comment: "")
//        }
//        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (action) -> Void in
//            _ = self.prefs.set(alert!.textFields![0].text, forKey: "username")
//            _ = self.prefs.set(alert!.textFields![1].text, forKey: "classes")
//            _ = self.prefs.set(alert!.textFields![2].text, forKey: "courses")
//            _ = self.prefs.synchronize()
//        }))
//
//        self.present(alert, animated: true, completion: nil)
    }
    
    
    
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

}
