//
//  DataFetcher.swift
//  AvH Plan
//
//  Created by Deniz Duezgoeren on 11.07.19.
//  Copyright © 2019 Deniz Duezgoeren. All rights reserved.
//

import UIKit
import Alamofire
import SwiftSoup
import SQLite

class DataFetcher {
    
    let path = Bundle.main.path(forResource: "db", ofType: "sqlite3")
    
    let substitutions = Table("substitutions")
    let id = Expression<Int64>("id")
    let group = Expression<String>("group")
    let course = Expression<String>("course")
    let additional = Expression<String>("additional")
    let date = Expression<String>("date")
    let time = Expression<String>("time")
    let room = Expression<String>("room")
    
    func doAsync(completionHandler: @escaping (_ substitutions: Array<SubstModel>) -> ()) {
        DispatchQueue(label: "work-queue").async {
            let url = "https://djd4rkn355.github.io/subst_test.html"
            Alamofire.request(url).responseString { response in
                if let html = response.result.value {
                    completionHandler(self.parseHTML(html: html))
                }
            }
            
        }
    }
    
    func parseHTML(html: String) -> Array<SubstModel> {
        var subst = Array<SubstModel>()
        do {
            let doc: Document = try SwiftSoup.parse(html)
            let rows: Elements = try doc.select("tr")
            
            let db = try Connection(path!)
            
            try db.run(substitutions.create { t in
                t.column(id, primaryKey: true)
                t.column(group)
                t.column(course)
                t.column(additional)
                t.column(date)
                t.column(time)
                t.column(room)
            })
            
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
            }
            
        } catch Exception.Error(let type, let message) {
            print(type)
            print(message)
        } catch {
            print("error")
        }
        return subst
    }
    
    func getFromDatabase() -> [SubstModel] {
        var substs = [SubstModel]()
        do {
            let db = try Connection(path!)
            for subst in try db.prepare(substitutions) {
                substs.append(SubstModel(group: subst[group], course: subst[course], additional: subst[additional], date: subst[date], time: subst[time], room: subst[room]))
            }
        } catch {}
        return substs
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
