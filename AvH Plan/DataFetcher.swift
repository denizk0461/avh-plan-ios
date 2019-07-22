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
    
    static let sharedInstance = DataFetcher()
    
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
    
    func doAsync(do task: String, completionHandler: @escaping (_ substitutions: [Any]) -> ()) {
        DispatchQueue(label: "work-queue").async {
            let foodUrl = "https://djd4rkn355.github.io/food.html"
            let url = "https://djd4rkn355.github.io/subst.html"
            Alamofire.request(url).responseString { response in
                if let html = response.result.value {
                    Alamofire.request(foodUrl).responseString { response in
                        if let foodHtml = response.result.value {
                            completionHandler(self.parseHTML(html: html, food: foodHtml, type: task))
                        }
                    }
                }
            }
        }
    }
    
    func parseHTML(html: String, food: String, type: String) -> [Any] {
        var subst = [SubstModel]()
        var personalSubst = [SubstModel]()
        var info = ""
        var infoList = [String]()
        var menuList = [String]()
        var isPersonalEmpty = true
        do {
            let doc = try SwiftSoup.parse(html)
            
            let rows: Elements = try doc.select("tr")
            
            let courses = prefs.string(forKey: "courses")
            let classes = prefs.string(forKey: "classes")
            
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
                            isPersonalEmpty = false
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
                                isPersonalEmpty = false
                            }
                        }
                    }
                }
                
            }
            
            if isPersonalEmpty {
                personalSubst.append(SubstModel(group: NSLocalizedString("personal_plan_empty", comment: ""), course: "", additional: "", date: "", time: "", room: ""))
                let insertPersonal = personal.insert(group <- NSLocalizedString("personal_plan_empty", comment: ""), course <- "", additional <- "", date <- "", time <- "", room <- "")
                _ = try db.run(insertPersonal)
            }
            
            let pi: Elements = try doc.select("p")
            
            for item in pi {
                if info.isEmpty {
                    info = try item.text()
                } else {
                    info += "\n\n\(try item.text())"
                }
            }
            _ = prefs.set(info, forKey: "information")
            
        } catch {}
        
        infoList.append(info)
        
        do {
            let foodDoc: Document = try SwiftSoup.parse(food)
            let ef: Elements = try foodDoc.select("th")
            
            let db = try Connection("\(path)/db.sqlite3")
            
            try db.run(foodmenu.create(ifNotExists: true) { t in
                t.column(id, primaryKey: true)
                t.column(text)
            })
            
            try db.run(foodmenu.delete())
            
            for i in 0..<ef.size() {
                menuList.append(try ef.get(i).text())
                let insert = foodmenu.insert(text <- try ef.get(i).text())
                _ = try db.run(insert)
            }
            
        } catch {}
        
        switch type {
        case "plan":
            return subst
        case "personal":
            return personalSubst
        case "info":
            return infoList
        default:
            return menuList
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
    
    func readInformation() -> String {
        return prefs.string(forKey: "information") ?? ""
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
    
    func getColourPalette() -> [UIColor] {
        return [#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), #colorLiteral(red: 1, green: 0.4932718873, blue: 0.4739984274, alpha: 1), #colorLiteral(red: 1, green: 0.5781051517, blue: 0, alpha: 1), #colorLiteral(red: 0.9995340705, green: 0.988355577, blue: 0.4726552367, alpha: 1), #colorLiteral(red: 0.4500938654, green: 0.9813225865, blue: 0.4743030667, alpha: 1), #colorLiteral(red: 0.4508578777, green: 0.9882974029, blue: 0.8376303315, alpha: 1), #colorLiteral(red: 0.4620226622, green: 0.8382837176, blue: 1, alpha: 1), #colorLiteral(red: 0.476841867, green: 0.5048075914, blue: 1, alpha: 1), #colorLiteral(red: 0.8446564078, green: 0.5145705342, blue: 1, alpha: 1), #colorLiteral(red: 1, green: 0.5409764051, blue: 0.8473142982, alpha: 1), #colorLiteral(red: 0.6745098039, green: 0.5568627451, blue: 0.4078431373, alpha: 1), #colorLiteral(red: 0.7540688515, green: 0.7540867925, blue: 0.7540771365, alpha: 1)]
    }
    
    func getColourPaletteNames() -> [String] {
        return [NSLocalizedString("white", comment: ""), NSLocalizedString("red", comment: ""), NSLocalizedString("orange", comment: ""), NSLocalizedString("yellow", comment: ""), NSLocalizedString("green", comment: ""), NSLocalizedString("cyan", comment: ""), NSLocalizedString("lightblue", comment: ""), NSLocalizedString("blue", comment: ""), NSLocalizedString("purple", comment: ""), NSLocalizedString("pink", comment: ""), NSLocalizedString("brown", comment: ""), NSLocalizedString("grey", comment: "")]
    }
    
    func getColour(for course: String) -> UIColor {
        if course.count >= 2 {
            let index = course.index(course.startIndex, offsetBy: 1)
            let s = course[...index].lowercased()
            var searchAgain = false
            var key = ""
            
            switch (s) {
            case "nw": key = "Biology"
            case "wp": key = "WP"
            default: searchAgain = true
            }
            
            if searchAgain && course.count >= 3 {
                let index1 = course.index(course.startIndex, offsetBy: 2)
                let s1 = course[...index1].lowercased()
                switch (s1) {
                case "deu", "dep", "daz", "fda": key = "German"
                case "mat", "map": key = "Maths"
                case "eng", "enp", "ena": key = "English"
                case "spo", "spp", "spth": key = "PhysEd"
                case "pol", "pop": key = "Politics"
                case "dar", "dap": key = "Theatre"
                case "phy", "php": key = "Physics"
                case "bio", "bip", "nw1", "nw2", "nw3", "nw4": key = "Biology"
                case "che", "chp": key = "Chemistry"
                case "phi", "psp": key = "Philosophy"
                case "laa", "laf", "lat": key = "Latin"
                case "spa", "spf": key = "Spanish"
                case "fra", "frf", "frz": key = "French"
                case "inf": key = "Compsci"
                case "ges": key = "History"
                case "rel": key = "Religion"
                case "geg": key = "Geography"
                case "kun": key = "Arts"
                case "mus": key = "Music"
                case "tue": key = "Turkish"
                case "chi": key = "Chinese"
                case "gll": key = "GLL"
                case "wat": key = "WAT"
                case "för": key = "Forder"
                case "met", "wpb": key = "WP"
                default: key = ""
                }
            }
            
            if key != "" {
                return self.getColourPalette()[prefs.integer(forKey: "colour-index-\(key)")]
            } else {
                return #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            }
        } else {
            return #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        }
    }
    
    let courses = ["German", "English", "French", "Spanish", "Latin", "Turkish", "Chinese", "Arts", "Music", "Theatre", "Geography", "History", "Politics", "Philosophy", "Religion", "Maths", "Biology", "Chemistry", "Physics", "CompSci", "PhysEd", "GLL", "WAT", "Forder", "WP"]
    
    let translatedCourses = [NSLocalizedString("german", comment: ""), NSLocalizedString("english", comment: ""), NSLocalizedString("french", comment: ""), NSLocalizedString("spanish", comment: ""), NSLocalizedString("latin", comment: ""), NSLocalizedString("turkish", comment: ""), NSLocalizedString("chinese", comment: ""), NSLocalizedString("arts", comment: ""), NSLocalizedString("music", comment: ""), NSLocalizedString("theatre", comment: ""), NSLocalizedString("geography", comment: ""), NSLocalizedString("history", comment: ""), NSLocalizedString("politics", comment: ""), NSLocalizedString("philosophy", comment: ""), NSLocalizedString("religion", comment: ""), NSLocalizedString("mathematics", comment: ""), NSLocalizedString("biology", comment: ""), NSLocalizedString("chemistry", comment: ""), NSLocalizedString("physics", comment: ""), NSLocalizedString("compsci", comment: ""), NSLocalizedString("physed", comment: ""), NSLocalizedString("gll", comment: ""), NSLocalizedString("wat", comment: ""), NSLocalizedString("forder", comment: ""), NSLocalizedString("wp", comment: "")]
}
