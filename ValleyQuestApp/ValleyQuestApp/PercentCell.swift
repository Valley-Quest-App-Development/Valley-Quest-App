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
            percentChanger.value = Float(roundToTens(newValue * 100.0))
            percentLabel.text = "\(roundToTens(newValue * 100.0))%"
        }
    }
    
    private func roundToTens(value: Double) -> Int {
        let thing = value / 10.0
        return 10 * Int(round(thing))
    }
    
    @IBAction func roundValue(sender: AnyObject) {
        percentChanger.setValue(Float(self.roundToTens(sender.value)), animated: true)
    }
    
    @IBAction func percentChanged(sender: UISlider) {
        percentLabel.text = "\(self.roundToTens(Double(sender.value)))%"
    }
}

class QualityCell: UITableViewCell {
    @IBOutlet weak var qualitySegmentedControl: UISegmentedControl!
}