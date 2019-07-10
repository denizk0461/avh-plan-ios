//
//  DataFetcher.swift
//  AvH Plan
//
//  Created by Deniz Duezgoeren on 11.07.19.
//  Copyright © 2019 Deniz Duezgoeren. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftSoup

class DataFetcher {
    
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
            
            for i in (0..<rows.size()) {
                let row = rows.get(i)
                let cols = try row.select("th")
                
                subst.append(SubstModel(group: try cols.get(0).text(), course: try cols.get(3).text(), additional: try cols.get(5).text(),
                                        date: try cols.get(1).text(), time: try cols.get(2).text(), room: try cols.get(4).text()))
                
            }
            
        } catch Exception.Error(let type, let message) {
            print(type)
            print(message)
        } catch {
            print("error")
        }
        return subst
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
