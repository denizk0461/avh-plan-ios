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
    let refreshControl = UIRefreshControl()
    let df = DataFetcher.sharedInstance
    let layout = MagazineLayout()
    var collectionView: UICollectionView
    var url = ""
    var indexOfPSA: Int? = nil
    
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
            collectionView.topAnchor.constraint(equalTo: view.topAnchor), // getToolbarBottomAnchor()),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            ])
        collectionView.register(UINib(nibName: "PlanViewCell", bundle: nil), forCellWithReuseIdentifier: identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        if #available(iOS 10.0, *) {
            collectionView.refreshControl = refreshControl
        } else {
            collectionView.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(objDoAsync(_:)), for: .valueChanged)
        refreshControl.tintColor = #colorLiteral(red: 0.07843137255, green: 0.5568627451, blue: 1, alpha: 1)
        refreshControl.attributedTitle = NSAttributedString(string: getRefreshViewString())
        
        self.substs = getFromDatabase()
        self.collectionView.reloadData()
    }
    
    func getViewType() -> String {
        return "plan"
    }
    
    func getFromDatabase() -> [SubstModel] {
        return self.df.getFromDatabase()
    }
    
    func getRefreshViewString() -> String {
        return NSLocalizedString("fetch_plan", comment: "")
    }
    
    @objc private func objDoAsync(_ sender: Any) {
        self.df.doAsync(do: self.getViewType()) { substitutions in
            self.substs = substitutions as! [SubstModel]
            self.collectionView.reloadData()
            self.refreshControl.endRefreshing()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.substs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexOfPSA == indexPath.item {
            UIApplication.shared.open(URL(string: url)!)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath as IndexPath) as! PlanViewCell
        cell.group.text = self.substs[indexPath.item].group
        cell.additional.text = self.substs[indexPath.item].additional
        cell.time.text = self.substs[indexPath.item].time
        
        var psa = false
        
        let course = self.substs[indexPath.item].course
        var image = df.getImage(from: course)
        
        cell.backgroundColor = self.df.getColour(for: course)
        cell.tintView.backgroundColor = cell.backgroundColor
        
        let dateString = self.substs[indexPath.item].date
        if dateString.count > 2 && dateString[dateString.startIndex...dateString.index(dateString.startIndex, offsetBy: 2)] == "psa" {
            cell.date.text = ""
            if dateString.count > 9 && dateString[dateString.index(dateString.startIndex, offsetBy: 3)...dateString.index(dateString.startIndex, offsetBy: 6)] == "http" {
                url = "\(dateString[dateString.index(dateString.startIndex, offsetBy: 3)...])"
                indexOfPSA = indexPath.item
            }
            image = UIImage(named: "ic_idea_w")
            cell.backgroundColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
            cell.tintView.backgroundColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
            cell.group.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            cell.course.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            cell.additional.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            psa = true
        } else {
            cell.date.text = self.substs[indexPath.item].date
            cell.group.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            cell.course.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            cell.additional.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        }
        
        let roomMutable = NSMutableAttributedString(string: self.substs[indexPath.item].room)
        let room = self.substs[indexPath.item].room
        if let qmark = room.firstIndex(of: "?") {
            let distance = room.distance(from: room.startIndex, to: qmark)
            roomMutable.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, distance))
        }
        cell.room.attributedText = roomMutable
        
        if image != nil {
            let attachment: NSTextAttachment = NSTextAttachment()
            if indexOfPSA == indexPath.item {
                attachment.bounds = CGRect(x: 0, y: 0, width: 11, height: 16)
            } else {
                attachment.bounds = CGRect(x: 0, y: 0, width: 16, height: 16)
            }
            attachment.image = image
            
            let courseImage = NSMutableAttributedString(string: "")
            courseImage.append(NSAttributedString(attachment: attachment))
            let courseString = NSAttributedString(string: " \(course)")
            courseImage.append(courseString)
            if psa == true {
                courseImage.addAttribute(NSAttributedString.Key.foregroundColor, value: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), range: NSMakeRange(0, 3))
            }
            
            cell.course.attributedText = courseImage
        } else {
            cell.course.text = course
        }
        
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
        return 0 // change this if needed
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetsForSectionAtIndex index: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetsForItemsInSectionAtIndex index: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}

