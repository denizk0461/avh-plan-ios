//
//  ColourPickerView.swift
//  AvH Plan
//
//  Created by Deniz Duezgoeren on 19.07.19.
//  Copyright © 2019 Deniz Duezgoeren. All rights reserved.
//

import UIKit
import MagazineLayout

class ColourPickerView: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateMagazineLayout {
    
    let identifier = "colour-cell"
    var course = ""
    var currentIndexPath: IndexPath? = nil
    var internalCourse = ""
    @IBOutlet weak var toolbar: UINavigationBar!
    let prefs = UserDefaults.standard
    let df = DataFetcher.sharedInstance
    var index = 0
    var key = ""
    @IBOutlet weak var collectionView: UICollectionView!
    var currentSelected: IndexPath? = nil
    var selectedNewItem = false
    
    @IBAction func done(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        key = "colour-index-\(internalCourse)"
        self.collectionView.register(UINib(nibName: "ColourViewCell", bundle: nil), forCellWithReuseIdentifier: identifier)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        index = prefs.integer(forKey: key)
        self.toolbar!.topItem!.title = "\(course)"
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // For removing the previous selection
        if currentSelected != nil {
            if let cell = collectionView.cellForItem(at: currentSelected!) as? ColourViewCell {
                cell.imageView.image = UIImage(named: "ic_empty")
            }
        }
        
        if let cell = collectionView.cellForItem(at: indexPath) as? ColourViewCell {
            cell.imageView.image = UIImage(named: "checkmark")
        }
        
        currentSelected = indexPath
        self.prefs.set(currentSelected!.item, forKey: key) // index is used for the colour array in DataFetcher
        
        // For reloading the selected cell
        self.collectionView.reloadItems(at: [currentSelected!])
        
        // For reloading the cell in the course picker view
        let dict: [String: IndexPath] = ["indexPath": currentIndexPath!]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil, userInfo: dict)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeModeForItemAt indexPath: IndexPath) -> MagazineLayoutItemSizeMode {
        let widthMode = MagazineLayoutItemWidthMode.fullWidth(respectsHorizontalInsets: true)
        let heightMode = MagazineLayoutItemHeightMode.static(height: 55)
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
        return self.df.getColourPalette().count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath as IndexPath) as! ColourViewCell
        cell.label.text = self.df.getColourPaletteNames()[indexPath.item]
        cell.colorView.layer.cornerRadius = cell.colorView.frame.height / 2
        cell.colorView.backgroundColor = self.df.getColourPalette()[indexPath.item]
        cell.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        cell.colorView.layer.borderWidth = 0.4
        cell.colorView.layer.borderColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        
        if currentSelected == indexPath {
            cell.imageView.image = UIImage(named: "checkmark")
        } else {
            cell.imageView.image = UIImage(named: "ic_empty")
        }
        
        if !selectedNewItem, indexPath.item == prefs.integer(forKey: key) {
            currentSelected = indexPath
            cell.imageView.image = UIImage(named: "checkmark")
            selectedNewItem = true
        }
        
        return cell
    }
}
