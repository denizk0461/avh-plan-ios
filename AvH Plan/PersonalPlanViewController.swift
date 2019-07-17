//
//  PersonalPlanViewController.swift
//  AvH Plan
//
//  Created by Deniz Duezgoeren on 16.07.19.
//  Copyright © 2019 Deniz Duezgoeren. All rights reserved.
//

import UIKit

class PersonalPlanViewController: PlanViewController {
    
    @IBOutlet weak var toolbar: UINavigationBar!
    let prefs = UserDefaults.standard
    
    @IBAction func toolbarButtonCustomise(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Customise personal page", message: nil, preferredStyle: .alert)
        alert.addTextField { (name) in
            name.text = self.prefs.string(forKey: "username")
            name.placeholder = "Name"
        }
        alert.addTextField { (classes) in
            classes.text = self.prefs.string(forKey: "classes")
            classes.placeholder = "Classes"
        }
        alert.addTextField { (courses) in
            courses.text = self.prefs.string(forKey: "courses")
            courses.placeholder = "Courses"
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (action) -> Void in
            _ = self.prefs.set(alert!.textFields![0].text, forKey: "username")
            _ = self.prefs.set(alert!.textFields![1].text, forKey: "classes")
            _ = self.prefs.set(alert!.textFields![2].text, forKey: "courses")
            _ = self.prefs.synchronize()
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let user = self.prefs.string(forKey: "username")
        if (user != nil && user != "") {
            if (user!.last == "x" || user!.last == "s" || user!.last == "z") {
                self.toolbar!.topItem!.title = "\(user!)' Plan"
            } else {
                self.toolbar!.topItem!.title = "\(user!)'s Plan"
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func getViewType() -> String {
        return "personal"
    }
    
    override func getRefreshViewString() -> String {
        return "Fetching your plan..."
    }
    
    override func getFromDatabase() -> [SubstModel] {
        return df.getPersonalFromDatabase()
    }
    
    override func getToolbarBottomAnchor() -> NSLayoutYAxisAnchor {
        return toolbar.bottomAnchor
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
