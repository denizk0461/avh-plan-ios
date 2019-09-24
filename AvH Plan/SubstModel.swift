//
//  SubstModel.swift
//  AvH Plan
//
//  Created by Deniz Duezgoeren on 09.07.19.
//  Copyright © 2019 Deniz Duezgoeren. All rights reserved.
//

import Foundation

class SubstModel {
    var group: String
    var course: String
    var additional: String
    var date: String
    var time: String
    var room: String
    var teacher: String
    var type: String
    var groupPriority: Int
    var datePriority: Int
    var websitePriority: Int
    
    init(group: String, course: String, additional: String, date: String, time: String, room: String, teacher: String, type: String, groupPriority: Int, datePriority: Int, websitePriority: Int) {
        self.group = group
        self.course = course
        self.additional = additional
        self.date = date
        self.time = time
        self.room = room
        self.teacher = teacher
        self.type = type
        self.groupPriority = groupPriority
        self.datePriority = datePriority
        self.websitePriority = websitePriority
    }
}
