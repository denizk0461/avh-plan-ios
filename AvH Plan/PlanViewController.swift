//
//  FirstViewController.swift
//  AvH Plan
//
//  Created by Deniz Duezgoeren on 25.05.19.
//  Copyright © 2019 Deniz Duezgoeren. All rights reserved.
//

import UIKit
import MagazineLayout

class PlanViewController : UIViewController, UICollectionViewDataSource, UICollectionViewDelegateMagazineLayout {
    
    let identifier = "plan_cell"
    var substs = [SubstModel]()
    private let refreshControl = UIRefreshControl()
    let df = DataFetcher()
    let layout = MagazineLayout()
    var collectionView: UICollectionView
    
    required init?(coder decoder: NSCoder) {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(coder: decoder)
    }
    
    func getToolbarBottomAnchor() -> NSLayoutYAxisAnchor {
        return view.topAnchor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: getToolbarBottomAnchor()),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            ])
        collectionView.register(UINib(nibName: "PlanViewCell", bundle: nil), forCellWithReuseIdentifier: identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        if #available(iOS 10.0, *) {
            collectionView.refreshControl = refreshControl
        } else {
            collectionView.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(objDoAsync(_:)), for: .valueChanged)
        refreshControl.tintColor = UIColor(red: 0.39, green: 0.71, blue: 0.96, alpha: 1.0)
        refreshControl.attributedTitle = NSAttributedString(string: getRefreshViewString())
    }
    
    func getViewType() -> String {
        return "plan"
    }
    
    func getFromDatabase() -> [SubstModel] {
        return self.df.getFromDatabase()
    }
    
    func getRefreshViewString() -> String {
        return "Fetching the plan..."
    }
    
    @objc private func objDoAsync(_ sender: Any) {
        df.doAsync(do: getViewType()) { substitutions in
            self.substs = substitutions as! [SubstModel]
            self.collectionView.reloadData()
            self.refreshControl.endRefreshing()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)
        
        self.substs = getFromDatabase()
        self.collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.substs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath as IndexPath) as! PlanViewCell
        if self.substs.count != 0 {
            cell.group.text = self.substs[indexPath.item].group
            cell.additional.text = self.substs[indexPath.item].additional
            cell.date.text = self.substs[indexPath.item].date
            cell.time.text = self.substs[indexPath.item].time
            cell.room.text = self.substs[indexPath.item].room
            
            let course = self.substs[indexPath.item].course
            let image = df.getImage(from: course)
            
            if image != nil {
                let attachment: NSTextAttachment = NSTextAttachment()
                attachment.bounds = CGRect(x: 0, y: 0, width: 16, height: 16)
                attachment.image = image
                
                let courseImage = NSMutableAttributedString(attachment: attachment)
                let courseString = NSAttributedString(string: " \(course)")
                courseImage.append(courseString)
                
                cell.course.attributedText = courseImage
            } else {
                cell.course.text = course
            }
        }
        
        cell.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        cell.tintView.backgroundColor = cell.backgroundColor
        return cell
    }
    
    // stubs
    
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
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetsForSectionAtIndex index: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetsForItemsInSectionAtIndex index: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}

