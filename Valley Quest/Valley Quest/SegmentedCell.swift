//
//  SegmentedCell.swift
//  Valley Quest App
//
//  Created by John Kotz on 3/28/16.
//  Copyright © 2016 vitalCommunities. All rights reserved.
//

import Foundation
import UIKit

class SegmentedCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var segment: UISegmentedControl!
    @IBOutlet weak var titleLabelWidth: NSLayoutConstraint!
    
    
    func setTitle(text: String) {
        titleLabel.text = text
        titleLabelWidth.constant = HelperMethods.getWidthForText(text, font: UIFont.systemFontOfSize(17))
    }
    
    func setSegments(segments: [String]) {
        segment.removeAllSegments()
        
        var i = 0
        for title in segments {
            segment.insertSegmentWithTitle(title, atIndex: i, animated: false)
            i += 1;
        }
    }
}