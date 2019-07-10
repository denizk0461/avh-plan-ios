//
//  FirstViewController.swift
//  AvH Plan
//
//  Created by Deniz Duezgoeren on 25.05.19.
//  Copyright © 2019 Deniz Duezgoeren. All rights reserved.
//

import UIKit
import SwiftSoup
import Alamofire
import SQLite3

class PlanViewController : UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    let reuseIdentifier = "cell"
    @IBOutlet weak var collectionView: UICollectionView!
    var substs = Array<SubstModel>()
    private let refreshControl = UIRefreshControl()
    var db: OpaquePointer?
    let df = DataFetcher()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if #available(iOS 10.0, *) {
            collectionView.refreshControl = refreshControl
        } else {
            collectionView.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(objDoAsync(_:)), for: .valueChanged)
        refreshControl.tintColor = UIColor(red: 0.39, green: 0.71, blue: 0.96, alpha: 1.0)
        refreshControl.attributedTitle = NSAttributedString(string: "Fetching the plan...")
    }
    
    @objc private func objDoAsync(_ sender: Any) {
        df.doAsync() { substitutions in
            self.substs = substitutions
            self.collectionView.reloadData()
            self.refreshControl.endRefreshing()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.substs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! CollectionViewCell
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
                attachment.bounds = CGRect(x: 0, y: 0, width: cell.course.frame.height - 6, height: cell.course.frame.height - 6)
                attachment.image = image
                
                let courseImage = NSMutableAttributedString(attachment: attachment)
                let courseString = NSAttributedString(string: " " + course)
                courseImage.append(courseString)
                
                cell.course.attributedText = courseImage
            } else {
                cell.course.text = course
            }
        }
        
//        cell.courseIcon.frame = CGRect(x: 0, y: 0, width: cell.course.frame.height, height: cell.course.frame.height)
        
//        cell.backgroundColor = UIColor(red: 0.39, green: 0.71, blue: 0.96, alpha: 1.0)
        cell.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        cell.tintView.backgroundColor = cell.backgroundColor
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("You selected cell#\(indexPath.item)!")
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.size.width, height: 108)
    }
}

