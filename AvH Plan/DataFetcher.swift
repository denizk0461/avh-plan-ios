//
//  DataFetcher.swift
//  AvH Plan
//
//  Created by Deniz Duezgoeren on 11.07.19.
//  Copyright © 2019 Deniz Duezgoeren. All rights reserved.
//

import UIKit
import Foundation
import SwiftSoup
import SQLite

class DataFetcher {
    
    static let sharedInstance = DataFetcher()
    
    let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
    let prefs = UserDefaults.standard
    let juniors = ["5", "6", "7", "8", "9"]
    
    var shouldRefresh: Bool
    
    init() {
        shouldRefresh = self.prefs.bool(forKey: "auto_refresh")
    }
    
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
    let teacher = Expression<String>("teacher")
    let subst_type = Expression<String>("type")
    let group_priority = Expression<Int64>("group_priority")
    let date_priority = Expression<Int64>("date_priority")
    let website_priority = Expression<Int64>("website_priority")
    
    let text = Expression<String>("text")
    
    func doAsync(do task: String, completionHandler: @escaping () -> ()) {
        DispatchQueue(label: "work-queue").async {
            self.fetchData(type: task)
            completionHandler()
        }
    }
    
    private func createTables(in db: Connection) -> Bool {
        do {
            try db.run(substitutions.create(ifNotExists: true) { t in
                t.column(id, primaryKey: true)
                t.column(group)
                t.column(course)
                t.column(additional)
                t.column(date)
                t.column(time)
                t.column(room)
                t.column(teacher)
                t.column(subst_type)
                t.column(group_priority)
                t.column(date_priority)
                t.column(website_priority)
            })
            
            try db.run(personal.create(ifNotExists: true) { t in
                t.column(id, primaryKey: true)
                t.column(group)
                t.column(course)
                t.column(additional)
                t.column(date)
                t.column(time)
                t.column(room)
                t.column(teacher)
                t.column(subst_type)
                t.column(group_priority)
                t.column(date_priority)
                t.column(website_priority)
            })
            
            try db.run(foodmenu.create(ifNotExists: true) { t in
                t.column(id, primaryKey: true)
                t.column(text)
            })
            
            return true
        } catch {
            return false
        }
    }
    
    private func clearDatabase(in db: Connection) {
        do {
            try db.run(substitutions.delete())
            try db.run(personal.delete())
            try db.run(foodmenu.delete())
        } catch {
        }
    }
    
    private func insert(into table: Table, substitution s: SubstModel) -> Insert {
        
        return table.insert(group <- s.group, course <- s.course, additional <- s.additional, date <- s.date, time <- s.time, room <- s.room, teacher <- s.teacher, subst_type <- s.type, group_priority <- Int64(s.groupPriority), date_priority <- Int64(s.datePriority), website_priority <- Int64(s.websitePriority))
    }
    
    private func isPersonal(with g: String, and c: String, for s: SubstModel) -> Bool {
        if !g.isEmpty && c.isEmpty {
            if !s.group.isEmpty {
                if g.contains(s.group) || s.group.contains(g) {
                    return true
                }
            }
        } else if !g.isEmpty && !c.isEmpty {
            if s.group != "" && s.course != "" {
                if (g.contains(s.group) || s.group.contains(g)) && c.contains(s.course) {
                    return true
                }
            }
        }
        return false
    }
    
    private func assignRanking(for group: String, _ isPSA: Bool) -> Int {
        if isPSA {
            return -102
        }
        
        if group.count > 0 {
            let a = String(group[...group.startIndex])
            if group.count > 1, let b = Int(String(group[group.index(group.startIndex, offsetBy: 0)...group.index(group.startIndex, offsetBy: 1)])) {
                return -b
            } else if self.checkStringForArray(s: a, checking: juniors, lowercase: false) == true {
                return -101
            } else {
                return -100
            }
        }
        
        return 0
    }
    
    private func assignDatePriority(for d: String, _ isPSA: Bool) -> Int? {
        
        if isPSA {
            return -1
        } else if d.isEmpty {
            return 13
        }
        
        let periodIndex = d.firstIndex(of: ".")
        
        return Int(String(d[d.index(periodIndex ?? d.startIndex, offsetBy: 1)...d.index(d.startIndex, offsetBy: d.count - 1)]))
    }
    
    private func fetchData(type: String) {
        var substitutionUrl = "https://djd4rkn355.github.io/avh_substitutions.html"
        var foodUrl = "https://djd4rkn355.github.io/food.html"
        
        if self.prefs.bool(forKey: "use_test_urls") {
            substitutionUrl = "https://djd4rkn355.github.io/subst_test.html"
            foodUrl = "https://djd4rkn355.github.io/food_test.html"
        }
        
        var isPersonalEmpty = true
        var personalPlanCount = 0
        var mWebsitePriority = 0
        
        var substitutionList = [SubstModel]()
        var personalList = [SubstModel]()
        var infoString = ""
        var foodmenuList = [String]()
        
        do {
            let db = try Connection("\(path)/db.sqlite3")
            _ = self.createTables(in: db)
            
            let substitutionContents = try String(contentsOf: URL(string: substitutionUrl)!, encoding: .utf8)
            let substitutionsDocument = try SwiftSoup.parse(substitutionContents)
            let rows = try substitutionsDocument.select("tr")
            
            let groupPreference = prefs.string(forKey: "classes")
            let coursePreference = prefs.string(forKey: "courses")
            
            for i in (0..<rows.size()) {
                let cols = try rows.get(i).select("th")
                
                let mGroup = try cols.get(0).text()
                let mCourse = try cols.get(3).text()
                let mAdditional = try cols.get(5).text()
                let mDate = try cols.get(1).text()
                let mTime = try cols.get(2).text()
                let mRoom = try cols.get(4).text()
                let mTeacher = try cols.get(6).text()
                let mType = try cols.get(7).text()
                
                var isPSA = false
                if mDate.count > 2 && mDate[...mDate.index(mDate.startIndex, offsetBy: 2)] == "psa" {
                    isPSA = true
                }
                
                let mDatePriority = self.assignDatePriority(for: mDate, isPSA) ?? 0
                let mGroupPriority = self.assignRanking(for: mGroup, isPSA)
                
                let substitution = SubstModel(group: mGroup, course: mCourse, additional: mAdditional, date: mDate, time: mTime, room: mRoom, teacher: mTeacher, type: mType, groupPriority: mGroupPriority, datePriority: mDatePriority, websitePriority: mWebsitePriority)
                
                mWebsitePriority += 1
                
                substitutionList.append(substitution)
                
                if self.isPersonal(with: groupPreference ?? "", and: coursePreference ?? "", for: substitution) || isPSA {
                    personalList.append(substitution)
                    if !isPSA {
                        isPersonalEmpty = false
                        personalPlanCount += 1
                    }
                }
            }
            
            if type == "personal" {
                personalPlanCount = 0
            }
            
            prefs.set(personalPlanCount, forKey: "personalPlanCount")
            
            if isPersonalEmpty {
                let emptySubstitution = SubstModel(group: "", course: NSLocalizedString("personal_plan_empty", comment: ""), additional: "", date: "", time: "", room: "", teacher: "", type: "", groupPriority: 0, datePriority: 0, websitePriority: 0)
                personalList.append(emptySubstitution)
            }
            
            // start info fetch
            // TODO: better documentation, please
            
            let lastUpdated = try substitutionsDocument.select("h1").get(0).text()
            infoString = "\(NSLocalizedString("last_updated", comment: ""))\(lastUpdated)."
            let informationTableElements = try substitutionsDocument.select("p")
            
            for item in informationTableElements {
                infoString += "\n\n\(try item.text())"
            }
            
            // start food fetch
            
            let foodContents = try String(contentsOf: URL(string: foodUrl)!, encoding: .utf8)
            let foodDocument = try SwiftSoup.parse(foodContents)
            let foodItems = try foodDocument.select("th")
            
            var indices = [Int]()
            let daysAndVon = ["montag", "dienstag", "mittwoch", "donnerstag", "freitag", "von", "wünschen"]
            for i in 0..<foodItems.size() {
                if checkStringForArray(s: try foodItems.get(i).text(), checking: daysAndVon, lowercase: true) {
                    indices.append(i)
                }
            }
            indices.append(foodItems.size())
            
            for l in 0..<indices.count - 1 {
                var s = ""
                for i2 in indices[l]..<indices[l + 1] {
                    if (s.isEmpty) {
                        s = try foodItems.get(i2).text()
                    } else {
                        s += "\n\(try foodItems.get(i2).text())"
                    }
                }
                foodmenuList.append(s)
            }
            
            self.clearDatabase(in: db)
            
            for subst in substitutionList {
                try db.run(self.insert(into: substitutions, substitution: subst))
            }
            
            for subst in personalList {
                try db.run(self.insert(into: personal, substitution: subst))
            }
            
            prefs.set(infoString.trimmingCharacters(in: .whitespacesAndNewlines), forKey: "information")
            
            for food in foodmenuList {
                try db.run(foodmenu.insert(text <- food))
            }
            
        } catch {
        }
    }
    
    private func checkStringForArray(s: String, checking: [String], lowercase: Bool) -> Bool {
        let str = lowercase ? s.lowercased() : s
        for i in checking.indices {
            if str.contains(checking[i]) {
                return true
            }
        }
        return false
    }

    
    func getSubstitutionsFromDatabase() -> [SubstModel] {
        var substs = [SubstModel]()
        do {
            let db = try Connection("\(path)/db.sqlite3")
            
            var table: AnySequence<Row>
            if !prefs.bool(forKey: "original_sorting") {
                table = try db.prepare(substitutions.order(date_priority.asc, date.asc, group_priority.asc, group.asc, time.asc))
            } else {
                table = try db.prepare(substitutions.order(website_priority.asc))
            }
            
            for subst in table {
                
                let substitution = SubstModel(group: subst[group], course: subst[course], additional: subst[additional], date: subst[date], time: subst[time], room: subst[room], teacher: subst[teacher], type: subst[subst_type], groupPriority: Int(subst[group_priority]), datePriority: Int(subst[date_priority]), websitePriority: Int(subst[website_priority]))
                
                substs.append(substitution)
            }
        } catch {
        }
        return substs
    }
    
    func getPersonalSubstitutionsFromDatabase() -> [SubstModel] {
        var personalSubsts = [SubstModel]()
        do {
            let db = try Connection("\(path)/db.sqlite3")
            
            var table: AnySequence<Row>
            if !prefs.bool(forKey: "original_sorting") {
                table = try db.prepare(personal.order(date_priority.asc, date.asc, group_priority.asc, group.asc, time.asc))
            } else {
                table = try db.prepare(personal.order(website_priority.asc))
            }
            
            for subst in table {
                
                let substitution = SubstModel(group: subst[group], course: subst[course], additional: subst[additional], date: subst[date], time: subst[time], room: subst[room], teacher: subst[teacher], type: subst[subst_type], groupPriority: Int(subst[group_priority]), datePriority: Int(subst[date_priority]), websitePriority: Int(subst[website_priority]))
                
                personalSubsts.append(substitution)
            }
        } catch {
        }
        return personalSubsts
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
        switch true {
        case i.contains("deu"), i.contains("dep"), i.contains("daz"): imagePath = "ic_german"
        case i.contains("mat"), i.contains("map"): imagePath = "ic_maths"
        case i.contains("eng"), i.contains("enp"), i.contains("ena"): imagePath = "ic_english"
        case i.contains("spo"), i.contains("spp"), i.contains("spth"): imagePath = "ic_pe"
        case i.contains("pol"), i.contains("pop"): imagePath = "ic_politics"
        case i.contains("dar"), i.contains("dap"): imagePath = "ic_drama"
        case i.contains("phy"), i.contains("php"): imagePath = "ic_physics"
        case i.contains("bio"), i.contains("bip"), i.contains("nw"): imagePath = "ic_biology"
        case i.contains("che"), i.contains("chp"): imagePath = "ic_chemistry"
        case i.contains("phi"), i.contains("psp"): imagePath = "ic_philosophy"
        case i.contains("laa"), i.contains("laf"), i.contains("lat"): imagePath = "ic_latin"
        case i.contains("spa"), i.contains("spf"): imagePath = "ic_spanish"
        case i.contains("fra") || i.contains("frf") || i.contains("frz"): imagePath = "ic_french"
        case i.contains("inf"): imagePath = "ic_compsci"
        case i.contains("ges"): imagePath = "ic_history"
        case i.contains("rel"): imagePath = "ic_religion"
        case i.contains("geg"), i.contains("wuk"): imagePath = "ic_geography"
        case i.contains("kun"): imagePath = "ic_arts"
        case i.contains("mus"): imagePath = "ic_music"
        case i.contains("tue"): imagePath = "ic_turkish"
        case i.contains("chi"): imagePath = "ic_chinese"
        case i.contains("gll"): imagePath = "ic_gll"
        case i.contains("wat"): imagePath = "ic_wat"
        case i.contains("för"): imagePath = "ic_help"
        case i.contains("wp"), i.contains("met"): imagePath = "ic_pencil"
        default: return nil
        }
        return UIImage(named: imagePath)
    }
    
    func getColourPalette() -> [UIColor] {
        return [UIColor(named: "colorDefault")!,
                UIColor(named: "colorRed")!,
                UIColor(named: "colorOrange")!,
                UIColor(named: "colorYellow")!,
                UIColor(named: "colorGreen")!,
                UIColor(named: "colorCyan")!,
                UIColor(named: "colorLightBlue")!,
                UIColor(named: "colorBlue")!,
                UIColor(named: "colorPurple")!,
                UIColor(named: "colorPink")!,
                UIColor(named: "colorBrown")!,
                UIColor(named: "colorGrey")!,
                UIColor(named: "colorRedAndroid")!,
                UIColor(named: "colorOrangeAndroid")!,
                UIColor(named: "colorYellowAndroid")!,
                UIColor(named: "colorGreenAndroid")!,
                UIColor(named: "colorCyanAndroid")!,
                UIColor(named: "colorLightBlueAndroid")!,
                UIColor(named: "colorBlueAndroid")!,
                UIColor(named: "colorPurpleAndroid")!,
                UIColor(named: "colorPinkAndroid")!,
                UIColor(named: "colorBrownAndroid")!]
    }
    
    func getColourPaletteNames() -> [String] {
        return [ls("white"), ls("red"), ls("orange"), ls("yellow"), ls("green"), ls("cyan"), ls("lightblue"), ls("blue"), ls("purple"), ls("pink"), ls("brown"), ls("grey"), ls("redA"), ls("orangeA"), ls("yellowA"), ls("greenA"), ls("cyanA"), ls("lightblueA"), ls("blueA"), ls("purpleA"), ls("pinkA"), ls("brownA")]
    }
    
    /// wrapper for returning a localized String without comment
    func ls(_ s: String) -> String {
        return NSLocalizedString(s, comment: "")
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
                return UIColor(named: "colorDefault")!
            }
        } else {
            return UIColor(named: "colorDefault")!
        }
    }
    
    let courses = ["German", "English", "French", "Spanish", "Latin", "Turkish", "Chinese", "Arts", "Music", "Theatre", "Geography", "History", "Politics", "Philosophy", "Religion", "Maths", "Biology", "Chemistry", "Physics", "CompSci", "PhysEd", "GLL", "WAT", "Forder", "WP"]
    
    let translatedCourses = [NSLocalizedString("german", comment: ""), NSLocalizedString("english", comment: ""), NSLocalizedString("french", comment: ""), NSLocalizedString("spanish", comment: ""), NSLocalizedString("latin", comment: ""), NSLocalizedString("turkish", comment: ""), NSLocalizedString("chinese", comment: ""), NSLocalizedString("arts", comment: ""), NSLocalizedString("music", comment: ""), NSLocalizedString("theatre", comment: ""), NSLocalizedString("geography", comment: ""), NSLocalizedString("history", comment: ""), NSLocalizedString("politics", comment: ""), NSLocalizedString("philosophy", comment: ""), NSLocalizedString("religion", comment: ""), NSLocalizedString("mathematics", comment: ""), NSLocalizedString("biology", comment: ""), NSLocalizedString("chemistry", comment: ""), NSLocalizedString("physics", comment: ""), NSLocalizedString("compsci", comment: ""), NSLocalizedString("physed", comment: ""), NSLocalizedString("gll", comment: ""), NSLocalizedString("wat", comment: ""), NSLocalizedString("forder", comment: ""), NSLocalizedString("wp", comment: "")]
    
    func setTabBarBadge(for tabBarItems: [UITabBarItem]?) {
        if let tabItems = tabBarItems {
            let tabItem = tabItems[1]
            if self.prefs.integer(forKey: "personalPlanCount") != 0 {
                tabItem.badgeValue = "\(self.prefs.integer(forKey: "personalPlanCount"))"
            } else {
                tabItem.badgeValue = nil
            }
        }
    }
    
    func setCardFormatting(for layer: CALayer) {
        layer.cornerRadius = 12.0
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        layer.shadowRadius = 1.2 // 1.5
        layer.shadowOpacity = 0.7
    }
    
    func presentInformationAlert(for tabBarController: UITabBarController, at index: Int) -> UIAlertController? {
        if tabBarController.selectedIndex == 2 {
            tabBarController.selectedIndex = index
            let alert = UIAlertController(title: NSLocalizedString("information", comment: ""), message: self.readInformation(), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("dismiss", comment: ""), style: .default) { action in
            })
            return alert
        } else {
            return nil
        }
    }
    
    func getInfoAlert(for type: String) -> UIAlertController {
        let alert = UIAlertController(title: NSLocalizedString("enter_\(type)_title", comment: ""), message: NSLocalizedString("enter_\(type)_help", comment: ""), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("dismiss", comment: ""), style: .default) { action in
        })
        return alert
    }
    
    func hasHomeButton() -> Bool {
        if #available(iOS 11.0, *), let keyWindow = UIApplication.shared.keyWindow, keyWindow.safeAreaInsets.bottom > 0 {
            return false
        }
        return true
    }
}
