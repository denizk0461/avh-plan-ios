//
//  DataFetcher.swift
//  AvH Plan
//
//  Created by Deniz Duezgoeren on 11.07.19.
//  Copyright © 2019 Deniz Duezgoeren. All rights reserved.
//

import UIKit
import Foundation
import Alamofire
import SwiftSoup
import SQLite

class DataFetcher {
    
    let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
    let prefs = UserDefaults.standard
    
    let substitutions = Table("substitutions")
    let personal = Table("personal")
    let information = Table("information")
    let foodmenu = Table("foodmenu")
    let id = Expression<Int64>("id")
    let group = Expression<String>("group")
    let course = Expression<String>("course")
    let additional = Expression<String>("additional")
    let date = Expression<String>("date")
    let time = Expression<String>("time")
    let room = Expression<String>("room")
    let text = Expression<String>("text")
    
    func doAsync(do task: String, completionHandler: @escaping (_ substitutions: Array<Any>) -> ()) {
        DispatchQueue(label: "work-queue").async {
            var url = ""
            switch task {
            case "menu": url = "https://djd4rkn355.github.io/food_test.html"
            default: url = "https://djd4rkn355.github.io/subst_test.html"
            }
            Alamofire.request(url).responseString { response in
                if let html = response.result.value {
                    switch task {
                    case "plan": completionHandler(self.parseHTML(html: html, isPersonal: false))
                    case "personal": completionHandler(self.parseHTML(html: html, isPersonal: true))
                    case "info": completionHandler(self.parseInformation(html: html))
                    default: completionHandler(self.parseMenu(html: html))
                    }
                    
                }
            }
            
        }
    }
    
    func parseHTML(html: String, isPersonal: Bool) -> Array<SubstModel> {
        var subst = Array<SubstModel>()
        var personalSubst = Array<SubstModel>()
        do {
            let doc: Document = try SwiftSoup.parse(html)
            let rows: Elements = try doc.select("tr")
            
            let courses = prefs.string(forKey: "courses")
            let classes = prefs.string(forKey: "classes")
//            let courses: String? = "GES7"
//            let classes: String? = "17"
            
            let db = try Connection("\(path)/db.sqlite3")
            
            try db.run(substitutions.create(ifNotExists: true) { t in
                t.column(id, primaryKey: true)
                t.column(group)
                t.column(course)
                t.column(additional)
                t.column(date)
                t.column(time)
                t.column(room)
            })
            
            try db.run(personal.create(ifNotExists: true) { t in
                t.column(id, primaryKey: true)
                t.column(group)
                t.column(course)
                t.column(additional)
                t.column(date)
                t.column(time)
                t.column(room)
            })
            
            try db.run(substitutions.delete())
            try db.run(personal.delete())
            
            for i in (0..<rows.size()) {
                let row = rows.get(i)
                let cols = try row.select("th")
                
                let mGroup = try cols.get(0).text()
                let mCourse = try cols.get(3).text()
                let mAdditional = try cols.get(5).text()
                let mDate = try cols.get(1).text()
                let mTime = try cols.get(2).text()
                let mRoom = try cols.get(4).text()
                
                subst.append(SubstModel(group: mGroup, course: mCourse, additional: mAdditional,
                                          date: mDate, time: mTime, room: mRoom))
                let insert = substitutions.insert(group <- mGroup, course <- mCourse, additional <- mAdditional,
                                                  date <- mDate, time <- mTime, room <- mRoom)
                _ = try db.run(insert)
                
                if courses == nil || courses == "", classes != nil && classes != "" {
                    if !mGroup.isEmpty && mGroup != "" {
                        if classes!.contains(mGroup) || mGroup.contains(classes!) {
                            personalSubst.append(SubstModel(group: mGroup, course: mCourse, additional: mAdditional,
                                                            date: mDate, time: mTime, room: mRoom))
                            let insertPersonal = personal.insert(group <- mGroup, course <- mCourse, additional <- mAdditional,
                                                                 date <- mDate, time <- mTime, room <- mRoom)
                            _ = try db.run(insertPersonal)
                        }
                    }
                } else if courses != nil && courses != "" && classes != nil && classes != "" {
                    if mGroup != "" && mCourse != "" {
                        if courses!.contains(mCourse) {
                            if classes!.contains(mGroup) || mGroup.contains(classes!) {
                                personalSubst.append(SubstModel(group: mGroup, course: mCourse, additional: mAdditional,
                                                                date: mDate, time: mTime, room: mRoom))
                                let insertPersonal = personal.insert(group <- mGroup, course <- mCourse, additional <- mAdditional,
                                                                     date <- mDate, time <- mTime, room <- mRoom)
                                _ = try db.run(insertPersonal)
                            }
                        }
                    }
                }
                
                
                
            }
            
        } catch Exception.Error(let type, let message) {
            print(type)
            print(message)
        } catch {
            print("error")
        }
        if isPersonal {
            return personalSubst
        } else {
            return subst
        }
    }
    
    func getFromDatabase() -> [SubstModel] {
        var substs = [SubstModel]()
        do {
            let db = try Connection("\(path)/db.sqlite3")
            for subst in try db.prepare(substitutions) {
                substs.append(SubstModel(group: subst[group], course: subst[course], additional: subst[additional], date: subst[date], time: subst[time], room: subst[room]))
            }
        } catch {}
        return substs
    }
    
    func getPersonalFromDatabase() -> [SubstModel] {
        var substs = [SubstModel]()
        do {
            let db = try Connection("\(path)/db.sqlite3")
            for subst in try db.prepare(personal) {
                substs.append(SubstModel(group: subst[group], course: subst[course], additional: subst[additional], date: subst[date], time: subst[time], room: subst[room]))
            }
        } catch {}
        return substs
    }
    
    func parseInformation(html: String) -> [String] {
        var info = ""
        do {
            let doc: Document = try SwiftSoup.parse(html)
            let p: Elements = try doc.select("p")
            
            for item in p {
                if info.isEmpty {
                    info = try item.text()
                } else {
                    info += "\n\n\(try item.text())"
                }
            }
            _ = prefs.set(info, forKey: "information")
            
        } catch Exception.Error(let type, let message) {
            print(type)
            print(message)
        } catch {
            print("error")
        }
        var list = [String]()
        list.append(info)
        return list
    }
    
    func readInformation() -> String {
        return prefs.string(forKey: "information") ?? ""
    }
    
    func parseMenu(html: String) -> [String] {
        
        var items = [String]()
        do {
            let doc: Document = try SwiftSoup.parse(html)
            let e: Elements = try doc.select("th")
            
            let db = try Connection("\(path)/db.sqlite3")
            
            try db.run(foodmenu.create(ifNotExists: true) { t in
                t.column(id, primaryKey: true)
                t.column(text)
            })
            
            try db.run(foodmenu.delete())
            
            for i in 0..<e.size() {
                items.append(try e.get(i).text())
                let insert = foodmenu.insert(text <- try e.get(i).text())
                _ = try db.run(insert)
            }
            
        } catch {}
        
        return items
    }
    
    func readMenu() -> [String] {
        var menu = [String]()
        do {
            let db = try Connection("\(path)/db.sqlite3")
            for item in try db.prepare(foodmenu) {
                menu.append(item[text])
            }
        } catch {}
        return menu
    }
    
    func getImage(from icon: String) -> UIImage? {
        var imagePath = ""
        let i = icon.lowercased()
        if i.contains("deu") || i.contains("dep") || i.contains("daz") {
            imagePath = "ic_german"
        } else if i.contains("mat") || i.contains("map") {
            imagePath = "ic_maths"
        } else if i.contains("eng") || i.contains("enp") || i.contains("ena") {
            imagePath = "ic_english"
        } else if i.contains("spo") || i.contains("spp") || i.contains("spth") {
            imagePath = "ic_pe"
        } else if i.contains("pol") || i.contains("pop") {
            imagePath = "ic_politics"
        } else if i.contains("dar") || i.contains("dap") {
            imagePath = "ic_drama"
        } else if i.contains("phy") || i.contains("php") {
            imagePath = "ic_physics"
        } else if i.contains("bio") || i.contains("bip") || i.contains("nw") {
            imagePath = "ic_biology"
        } else if i.contains("che") || i.contains("chp") {
            imagePath = "ic_chemistry"
        } else if i.contains("phi") || i.contains("psp") {
            imagePath = "ic_philosophy"
        } else if i.contains("laa") || i.contains("laf") || i.contains("lat") {
            imagePath = "ic_latin"
        } else if i.contains("spa") || i.contains("spf") {
            imagePath = "ic_spanish"
        } else if i.contains("fra") || i.contains("frf") || i.contains("frz") {
            imagePath = "ic_french"
        } else if i.contains("inf") {
            imagePath = "ic_compsci"
        } else if i.contains("ges") {
            imagePath = "ic_history"
        } else if i.contains("rel") {
            imagePath = "ic_religion"
        } else if i.contains("geg") || i.contains("wuk") {
            imagePath = "ic_geography"
        } else if i.contains("kun") {
            imagePath = "ic_arts"
        } else if i.contains("mus") {
            imagePath = "ic_music"
        } else if i.contains("tue") {
            imagePath = "ic_turkish"
        } else if i.contains("chi") {
            imagePath = "ic_chinese"
        } else if i.contains("gll") {
            imagePath = "ic_gll"
        } else if i.contains("wat") {
            imagePath = "ic_wat"
        } else if i.contains("för") {
            imagePath = "ic_help"
        } else if i.contains("wp") || i.contains("met") {
            imagePath = "ic_pencil"
        } else {
            return nil
        }
        return UIImage(named: imagePath)
    }
}
