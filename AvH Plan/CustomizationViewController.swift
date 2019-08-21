//
//  CustomizationViewController.swift
//  AvH Plan
//
//  Created by Deniz Duezgoeren on 19.07.19.
//  Copyright © 2019 Deniz Duezgoeren. All rights reserved.
//

import UIKit
import MagazineLayout

class CustomizationViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateMagazineLayout, UITextFieldDelegate {

    var courses = [String]()
    var translatedCourses = [String]()
    @IBOutlet weak var collectionView: UICollectionView!
    let identifier = "customisation_cell"
//    let storyboard = UIStoryboard(name: "main", bundle: nil)
    let prefs = UserDefaults.standard
    let df = DataFetcher.sharedInstance
    
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtClasses: UITextField!
    @IBOutlet weak var txtCourses: UITextField!
    @IBOutlet weak var defaultSegments: UISegmentedControl!
    
    @IBOutlet weak var textToolbar: UIToolbar!
    
    @IBAction func textDismissButton(_ sender: Any) {
        view.endEditing(true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.inputAccessoryView = textToolbar
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        courses = self.df.courses
        translatedCourses = self.df.translatedCourses
        self.collectionView.register(UINib(nibName: "ColourViewCell", bundle: nil), forCellWithReuseIdentifier: identifier)
    }
    
    @IBAction func done(_ sender: UIBarButtonItem) {
        
        self.prefs.set(self.txtName.text, forKey: "username")
        self.prefs.set(self.txtClasses.text, forKey: "classes")
        self.prefs.set(self.txtCourses.text, forKey: "courses")
        self.prefs.set(self.defaultSegments.selectedSegmentIndex, forKey: "default-plan")
        
        self.prefs.synchronize()
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.txtName.delegate = self
        self.txtClasses.delegate = self
        self.txtCourses.delegate = self
        
        self.txtName.text = prefs.string(forKey: "username")
        self.txtClasses.text = prefs.string(forKey: "classes")
        self.txtCourses.text = prefs.string(forKey: "courses")
        self.defaultSegments.selectedSegmentIndex = prefs.integer(forKey: "default-plan")
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadList), name:NSNotification.Name(rawValue: "load"), object: nil)
    }
    
    @objc func loadList(notification: NSNotification){
        self.collectionView.reloadItems(at: [notification.userInfo?["indexPath"] as! IndexPath])
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let s = storyboard?.instantiateViewController(withIdentifier: "ColourPickerView") as? ColourPickerView {
            s.course = self.translatedCourses[indexPath.item]
            s.internalCourse = self.courses[indexPath.item]
            s.currentIndexPath = indexPath
            self.present(s, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeModeForItemAt indexPath: IndexPath) -> MagazineLayoutItemSizeMode {
        let widthMode = MagazineLayoutItemWidthMode.fullWidth(respectsHorizontalInsets: true)
        let heightMode = MagazineLayoutItemHeightMode.dynamic
        return MagazineLayoutItemSizeMode(widthMode: widthMode, heightMode: heightMode)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, visibilityModeForHeaderInSectionAtIndex index: Int) -> MagazineLayoutHeaderVisibilityMode {
        return .hidden
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, visibilityModeForFooterInSectionAtIndex index: Int) -> MagazineLayoutFooterVisibilityMode {
        return .hidden
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, visibilityModeForBackgroundInSectionAtIndex index: Int) -> MagazineLayoutBackgroundVisibilityMode {
        return .hidden
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, horizontalSpacingForItemsInSectionAtIndex index: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, verticalSpacingForElementsInSectionAtIndex index: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetsForSectionAtIndex index: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetsForItemsInSectionAtIndex index: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.courses.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath as IndexPath) as! ColourViewCell
        cell.label.text = self.translatedCourses[indexPath.item]
        cell.colorView.layer.cornerRadius = cell.colorView.frame.height / 2
        cell.colorView.layer.borderWidth = 0.4
        cell.colorView.layer.borderColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        cell.colorView.backgroundColor = self.df.getColourPalette()[prefs.integer(forKey: "colour-index-\(courses[indexPath.item])")]
        cell.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        return cell
    }
}
