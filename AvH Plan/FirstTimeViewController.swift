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
    
    var activeTextField: UITextField?
    
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
        self.activeTextField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.activeTextField = nil
    }
    
    func registerForKeyboardNotifications(){
        //Adding notifies on keyboard appearing
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    func deregisterFromKeyboardNotifications(){
        //Removing notifies on keyboard appearing
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func keyboardWasShown(notification: NSNotification){
        //Need to calculate keyboard exact size due to Apple suggestions
        self.scrollView.isScrollEnabled = true
        let info = notification.userInfo!
        let keyboardSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets: UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize!.height + self.textToolbar.frame.height, right: 0.0)

        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets

        var aRect: CGRect = self.view.frame
        aRect.size.height -= keyboardSize!.height
        if let activeField = self.activeTextField {
            if (!aRect.contains(activeField.frame.origin)) {
                self.scrollView.scrollRectToVisible(activeField.frame, animated: true)
            }
        }
    }

    @objc func keyboardWillBeHidden(notification: NSNotification){
        //Once keyboard disappears, restore original positions
        let info = notification.userInfo!
        let keyboardSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets: UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: -(keyboardSize!.height + self.textToolbar.frame.height), right: 0.0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        self.view.endEditing(true)
        self.scrollView.isScrollEnabled = false
    }
    
    @IBAction func finishSetupButton(_ sender: UIBarButtonItem) {
        self.prefs.set(self.nameTextField.text, forKey: "username")
        self.prefs.set(self.gradeTextField.text, forKey: "classes")
        self.prefs.set(self.courseTextField.text, forKey: "courses")
        self.prefs.set(self.defaultPlanSegmentedControl.selectedSegmentIndex, forKey: "default-plan")
        self.prefs.set(true, forKey: "setup_finished")
        self.prefs.set(true, forKey: "auto_refresh")
        
        if let s = storyboard?.instantiateViewController(withIdentifier: "AppTabBarController") as? CustomTabBarController {
            s.modalPresentationStyle = .fullScreen
            self.present(s, animated: true)
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.registerForKeyboardNotifications()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.nameTextField.delegate = self
        self.gradeTextField.delegate = self
        self.courseTextField.delegate = self
        self.scrollView.isDirectionalLockEnabled = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.deregisterFromKeyboardNotifications()
    }
}
