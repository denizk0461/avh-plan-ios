//
//  CustomizationViewController.swift
//  AvH Plan
//
//  Created by Deniz Duezgoeren on 19.07.19.
//  Copyright © 2019 Deniz Duezgoeren. All rights reserved.
//

import UIKit

class CustomizationViewController: UITableViewController, UITextFieldDelegate {

    let prefs = UserDefaults.standard
    let df = DataFetcher.sharedInstance
    
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtClasses: UITextField!
    @IBOutlet weak var txtCourses: UITextField!
    @IBOutlet weak var defaultSwitch: UISwitch!
    @IBOutlet weak var textToolbar: UIToolbar!
    @IBOutlet weak var orderingSegments: UISegmentedControl!
    @IBOutlet weak var autoRefreshToggle: UISwitch!
    
    @IBAction func textDismissButton(_ sender: UIBarButtonItem) {
        view.endEditing(true)
    }
    
    @IBAction func groupHelpButton(_ sender: UIButton) {
        self.present(self.df.getInfoAlert(for: "grade"), animated: true)
    }
    
    @IBAction func courseHelpButton(_ sender: UIButton) {
        self.present(self.df.getInfoAlert(for: "course"), animated: true)
    }
    
    @IBAction func orderHelpButton(_ sender: UIButton) {
        self.present(self.df.getInfoAlert(for: "order"), animated: true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.inputAccessoryView = textToolbar
    }
    
    @IBAction func done(_ sender: UIBarButtonItem) {
        
        self.prefs.set(self.txtName.text, forKey: "username")
        self.prefs.set(self.txtClasses.text, forKey: "classes")
        self.prefs.set(self.txtCourses.text, forKey: "courses")
        
        var defaultPlan: Int
        if self.defaultSwitch.isOn {
            defaultPlan = 1
        } else {
            defaultPlan = 0
        }
        self.prefs.set(defaultPlan, forKey: "default-plan")
        self.prefs.set(self.orderingSegments.selectedSegmentIndex == 1, forKey: "original_sorting")
        self.prefs.set(self.autoRefreshToggle.isOn, forKey: "auto_refresh")
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func customizeColoursButton(_ sender: UIButton) {
        if let s = storyboard?.instantiateViewController(withIdentifier: "CoursePickerViewController") as? CoursePickerViewController {
            self.present(s, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.txtName.delegate = self
        self.txtClasses.delegate = self
        self.txtCourses.delegate = self
        
        self.txtName.text = prefs.string(forKey: "username")
        self.txtClasses.text = prefs.string(forKey: "classes")
        self.txtCourses.text = prefs.string(forKey: "courses")
        if self.prefs.integer(forKey: "default-plan") == 1 {
            self.defaultSwitch.isOn = true
        } else {
            self.defaultSwitch.isOn = false
        }
        var order: Int
        if self.prefs.bool(forKey: "original_sorting") {
            order = 1
        } else {
            order = 0
        }
        self.orderingSegments.selectedSegmentIndex = order
        self.autoRefreshToggle.isOn = self.prefs.bool(forKey: "auto_refresh")
    }
}
