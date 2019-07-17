//
//  InfoViewController.swift
//  AvH Plan
//
//  Created by Deniz Duezgoeren on 10.07.19.
//  Copyright © 2019 Deniz Duezgoeren. All rights reserved.
//

import UIKit

class InfoViewController : UIViewController {
    
    @IBOutlet weak var content: UILabel!
    let prefs = UserDefaults.standard
    @IBOutlet weak var scrollView: UIScrollView!
    private let refreshControl = UIRefreshControl()
    let df = DataFetcher() // should be a static reference
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if #available(iOS 10.0, *) {
            scrollView.refreshControl = refreshControl
        } else {
            scrollView.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(objDoAsync(_:)), for: .valueChanged)
        refreshControl.tintColor = UIColor(red: 0.39, green: 0.71, blue: 0.96, alpha: 1.0)
        refreshControl.attributedTitle = NSAttributedString(string: "Fetching some information...")
        self.scrollView.isDirectionalLockEnabled = true
    }
    
    @objc private func objDoAsync(_ sender: Any) {
        self.df.doAsync(do: "info") { infoArray in
            self.content.text = infoArray[0] as? String
            self.refreshControl.endRefreshing()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        content.text = df.readInformation()
    }
}
