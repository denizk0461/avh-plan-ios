//
//  CollectionViewCell.swift
//  AvH Plan
//
//  Created by Deniz Duezgoeren on 25.05.19.
//  Copyright © 2019 Deniz Duezgoeren. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var group: UILabel!
    @IBOutlet weak var course: UILabel!
    @IBOutlet weak var additional: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var room: UILabel!
    @IBOutlet weak var tintView: UIView!
}
