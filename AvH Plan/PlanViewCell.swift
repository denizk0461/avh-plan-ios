//
//  PlanViewCell.swift
//  AvH Plan
//
//  Created by Deniz Duezgoeren on 16.07.19.
//  Copyright © 2019 Deniz Duezgoeren. All rights reserved.
//

import UIKit

class PlanViewCell: GenericViewCell {
    
    @IBOutlet weak var group: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var course: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var additional: UILabel!
    @IBOutlet weak var room: UILabel!
    @IBOutlet weak var tintView: UIView!
    @IBOutlet weak var teacher: UILabel!
}
