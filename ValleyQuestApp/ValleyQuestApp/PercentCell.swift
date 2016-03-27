//
//  PercentCell.swift
//  Valley Quest App
//
//  Created by John Kotz on 3/24/16.
//  Copyright © 2016 vitalCommunities. All rights reserved.
//

import Foundation
import BEMCheckBox

class PercentCell: UITableViewCell {
    @IBOutlet weak var percentLabel: UILabel!
    @IBOutlet weak var percentChanger: UISlider!
    
    var percent: Double {
        get {
            return Double(percentChanger.value)/100.0
        }
        set {
            percentChanger.value = Float(round(newValue * 100.0))
            percentLabel.text = "\(Int(round(newValue * 100.0)))%"
        }
    }
    
    @IBAction func percentChanged(sender: UISlider) {
        percentLabel.text = "\(Int(round(sender.value)))%"
    }
}

class QualityCell: UITableViewCell {
    @IBOutlet weak var qualitySegmentedControl: UISegmentedControl!
}