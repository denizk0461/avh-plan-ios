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

class FirstViewController : UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
        
    let reuseIdentifier = "cell"
    @IBOutlet weak var collectionView: UICollectionView!
    let queue = DispatchQueue(label: "work-queue")
    var group: Array<String> = Array()
    var course: Array<String> = Array()
    var additional: Array<String> = Array()
    var date: Array<String> = Array()
    var time: Array<String> = Array()
    var room: Array<String> = Array()
    private let refreshControl = UIRefreshControl()
    var db: OpaquePointer?
    
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
        self.refreshControl.beginRefreshing()
        self.doAsync()
    }
    
    @objc private func objDoAsync(_ sender: Any) {
        self.doAsync()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.backgroundColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)
        
//        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
//        layout.itemSize = CGSize(width: view.frame.size.width, height: 129)
        
//        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
//        .appendingPathComponent("SubstDB.sqlite")
//
//        if (sqlite3_open(fileURL.path, &db) != SQLITE_OK) {
//            print("Error opening database connection")
//        }
//        sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS subst_table (id INTEGER PRIMARY KEY AUTOINCREMENT, group TEXT, course TEXT, add TEXT, date TEXT, time TEXT, room TEXT)", nil, nil, nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.group.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! CollectionViewCell
        if self.group.count != 0 {
            cell.group.text = self.group[indexPath.item]
            cell.course.text = self.course[indexPath.item]
            cell.additional.text = self.additional[indexPath.item]
            cell.date.text = self.date[indexPath.item]
            cell.time.text = self.time[indexPath.item]
            cell.room.text = self.room[indexPath.item]
        }
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
    
    func doAsync() {
        queue.async {
            let url = "https://djd4rkn355.github.io/subst_test.html"
            Alamofire.request(url).responseString { response in
                if let html = response.result.value {
                    self.parseHTML(html: html)
                }
            }
            
        }
    }
    
    func insertInDb() {
        
//        let insertString = "INSERT INTO subst_table VALUES (?, ?, ?, ?, ?, ?)"
//
//        if (sqlite3_prepare_v2(db, insertString, nil, nil, nil) != SQLITE_OK) {
//            print("error db")
//        }
//        if (
    }
    
    func parseHTML(html: String) {
        do {
            let doc: Document = try SwiftSoup.parse(html)
            let rows: Elements = try doc.select("tr")
            
            self.group.removeAll()
            self.date.removeAll()
            self.time.removeAll()
            self.course.removeAll()
            self.room.removeAll()
            self.additional.removeAll()
            
            var group: String
            var date: String
            var time: String
            var course: String
            var room: String
            var add: String
            
//            sqlite3_exec(db, "DELETE FROM subst_table", nil, nil, nil)
            
            for i in (0..<rows.size()) {
                let row = rows.get(i)
                let cols = try row.select("th")
                
                group = try cols.get(0).text()
                date = try cols.get(1).text()
                time = try cols.get(2).text()
                course = try cols.get(3).text()
                room = try cols.get(4).text()
                add = try cols.get(5).text()
                
                self.group.append(group)
                self.date.append(date)
                self.time.append(time)
                self.course.append(course)
                self.room.append(room)
                self.additional.append(add)
                
                // insert()
            }
            
            self.collectionView.reloadData() // reloadData() only produces 13 cells, no more, no less
            // nevermind, but it depends on the "items" array, for some reason??
//            self.updateView()
            self.refreshControl.endRefreshing()
//            self.activityIndicatorView.stopAnimating()
        } catch Exception.Error(let type, let message) {
            print(type)
            print(message)
        } catch {
            print("error")
        }
    }
}

