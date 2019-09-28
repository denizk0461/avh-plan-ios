//
//  FirstTimeViewController.swift
//  AvH Plan
//
//  Created by Deniz Duezgoeren on 21.09.19.
//  Copyright © 2019 Deniz Duezgoeren. All rights reserved.
//

import UIKit

class FirstTimeViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    let df = DataFetcher.sharedInstance
    let prefs = UserDefaults.standard
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var gradeTextField: UITextField!
    @IBOutlet weak var courseTextField: UITextField!
    @IBOutlet weak var defaultPlanSegmentedControl: UISegmentedControl!
    @IBOutlet weak var textToolbar: UIToolbar!
    
    @IBAction func gradeInfoButton(_ sender: UIButton) {
        self.present(self.df.getInfoAlert(for: "grade"), animated: true)
    }
    
    @IBAction func courseInfoButton(_ sender: UIButton) {
        self.present(self.df.getInfoAlert(for: "course"), animated: true)
    }
    
    @IBAction func textDismissButton(_ sender: UIBarButtonItem) {
        view.endEditing(true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.inputAccessoryView = textToolbar
    }
    
    @IBAction func finishSetupButton(_ sender: UIBarButtonItem) {
        self.prefs.set(self.nameTextField.text, forKey: "username")
        self.prefs.set(self.gradeTextField.text, forKey: "classes")
        self.prefs.set(self.courseTextField.text, forKey: "courses")
        self.prefs.set(self.defaultPlanSegmentedControl.selectedSegmentIndex, forKey: "default-plan")
        self.prefs.set(true, forKey: "setup_finished")
        self.prefs.set(true, forKey: "auto_refresh")
        
        if let s = storyboard?.instantiateViewController(withIdentifier: "AppTabBarController") as? CustomTabBarController {
            self.present(s, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.nameTextField.delegate = self
        self.gradeTextField.delegate = self
        self.courseTextField.delegate = self
        self.scrollView.isDirectionalLockEnabled = true
    }

}
