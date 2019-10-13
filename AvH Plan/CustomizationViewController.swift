//
//  CustomizationViewController.swift
//  AvH Plan
//
//  Created by Deniz Duezgoeren on 19.07.19.
//  Copyright © 2019 Deniz Duezgoeren. All rights reserved.
//

import UIKit
import Crashlytics
import Toast_Swift

class CustomizationViewController: UITableViewController, UITextFieldDelegate, UIAdaptivePresentationControllerDelegate {

    let prefs = UserDefaults.standard
    let df = DataFetcher.sharedInstance
    var buttonTextChanged = false
    
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtClasses: UITextField!
    @IBOutlet weak var txtCourses: UITextField!
    @IBOutlet weak var defaultSwitch: UISwitch!
    @IBOutlet weak var textToolbar: UIToolbar!
    @IBOutlet weak var orderingSegments: UISegmentedControl!
    @IBOutlet weak var autoRefreshToggle: UISwitch!
    @IBOutlet weak var customizeCourseColorsButton: UIButton!
    
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
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func customizeColoursButton(_ sender: UIButton) {
        if let s = storyboard?.instantiateViewController(withIdentifier: "CoursePickerViewController") as? CoursePickerViewController {
            self.present(s, animated: true)
        }
    }
    
    @IBAction func longPressListener(_ sender: UILongPressGestureRecognizer) {
        sender.minimumPressDuration = 2
        if sender.state == .ended {
            if !buttonTextChanged {
                self.customizeCourseColorsButton.setTitle(NSLocalizedString("made_by_deniz", comment: ""), for: .normal)
                buttonTextChanged = true
            } else {
                self.customizeCourseColorsButton.setTitle(NSLocalizedString("customize_course_colors", comment: ""), for: .normal)
                buttonTextChanged = false
            }
        }
    }
    
    @IBAction func infoLongPressListener(_ sender: UILongPressGestureRecognizer) {
        sender.minimumPressDuration = 2
        if sender.state == .ended {
            let youtubeId = "Jc2xfYuLWgE"
            if let youtubeURL = URL(string: "youtube://\(youtubeId)"),
                UIApplication.shared.canOpenURL(youtubeURL) {
                // redirect to app
                UIApplication.shared.open(youtubeURL, options: [:], completionHandler: nil)
            } else if let youtubeURL = URL(string: "https://www.youtube.com/watch?v=\(youtubeId)") {
                // redirect through safari
                UIApplication.shared.open(youtubeURL, options: [:], completionHandler: nil)
            }
        }
    }
    
    @IBAction func openHiddenInputDialog(_ sender: UILongPressGestureRecognizer) {
        sender.minimumPressDuration = 2
        if sender.state == .ended {
            let alert = UIAlertController(title: NSLocalizedString("hidden_dialog_title", comment: ""), message: NSLocalizedString("hidden_dialog_desc", comment: ""), preferredStyle: .alert)
            alert.addTextField { textField in }
            alert.addAction(UIAlertAction(title: NSLocalizedString("apply", comment: ""), style: .default, handler: { [weak alert] (action) -> Void in
                let toastMessage: String
                switch alert!.textFields![0].text {
                    case "_firsttime":
                        self.prefs.set(false, forKey: "setup_finished")
                        toastMessage = "First time flag cleared"
                        break
                    case "_login":
                        self.prefs.set(false, forKey: "logged_in")
                        toastMessage = "Login flag cleared"
                        break
                    case "_devchannel":
                        let newValue = !self.prefs.bool(forKey: "subscribed_to_dev_channel")
                        self.prefs.set(newValue, forKey: "subscribed_to_dev_channel")
                        let sub: String
                        if newValue {
                            sub = "Subscribed to"
                        } else {
                            sub = "Unsubscribed from"
                        }
                        toastMessage = "\(sub) Firebase development channel"
                        break
                    case "_crash":
                        toastMessage = ""
                        Crashlytics.sharedInstance().crash()
                        break
                    case "_testurls":
                        let newValue = !self.prefs.bool(forKey: "use_test_urls")
                        self.prefs.set(newValue, forKey: "use_test_urls")
                        toastMessage = "Test URLs set to \(newValue)"
                        break
                    default:
                        toastMessage = NSLocalizedString("invalid_code", comment: "")
                        break
                }
                self.view.makeToast(toastMessage, position: .center)
            }))
            self.present(alert, animated: true, completion: nil)

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
        self.defaultSwitch.isOn = self.prefs.integer(forKey: "default-plan") == 1 ? true : false
        let order = self.prefs.bool(forKey: "original_sorting") ? 1 : 0
        self.orderingSegments.selectedSegmentIndex = order
        self.autoRefreshToggle.isOn = self.prefs.bool(forKey: "auto_refresh")
        
        if #available(iOS 13.0, *) {
            presentedViewController?.isModalInPresentation = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.savePreferences()
    }
    
    private func savePreferences() {
        self.prefs.set(self.txtName.text, forKey: "username")
        self.prefs.set(self.txtClasses.text, forKey: "classes")
        self.prefs.set(self.txtCourses.text, forKey: "courses")
        
        let defaultPlan = self.defaultSwitch.isOn ? 1 : 0
        self.prefs.set(defaultPlan, forKey: "default-plan")
        self.prefs.set(self.orderingSegments.selectedSegmentIndex == 1, forKey: "original_sorting")
        self.prefs.set(self.autoRefreshToggle.isOn, forKey: "auto_refresh")
    }
}
