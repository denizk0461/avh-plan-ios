//
//  GeneralViewController.swift
//  AvH Plan
//
//  Created by Deniz Duezgoeren on 16.07.19.
//  Copyright © 2019 Deniz Duezgoeren. All rights reserved.
//

import UIKit

class GeneralViewController: PlanViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.topItem?.title = NSLocalizedString("avh_plan", comment: "")
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
    
}
