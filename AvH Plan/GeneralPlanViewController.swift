//
//  GeneralViewController.swift
//  AvH Plan
//
//  Created by Deniz Duezgoeren on 16.07.19.
//  Copyright © 2019 Deniz Duezgoeren. All rights reserved.
//

import UIKit

class GeneralViewController: PlanViewController {
    
    @IBOutlet weak var toolbar: UINavigationBar!    

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func getViewType() -> String {
        return "plan"
    }
    
    override func getRefreshViewString() -> String {
        return NSLocalizedString("fetch_plan", comment: "")
    }
    
    override func getFromDatabase() -> [SubstModel] {
        return df.getFromDatabase()
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
