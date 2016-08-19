//
//  TestViewController.swift
//  Valley Quest
//
//  Created by John Kotz on 8/18/16.
//  Copyright © 2016 Valley Quest. All rights reserved.
//

import Foundation
import UIKit

class TestViewController: UIViewController {
    
    @IBOutlet weak var selector: NPSegmentedControl!
    
    override func viewDidLoad() {
        
        selector.cursor = UIImageView(image: UIImage(named: "tabindicator"))
        selector.setItems(["All quests", "Near me"]);
        selector.backgroundColor = UIColor.clearColor()
        selector.unselectedFont = UIFont(name: "AvenirNext", size: 16)
        selector.selectedFont = UIFont(name: "AvenirNext-Bold", size: 16)
        selector.unselectedTextColor = UIColor(white: 1, alpha: 0.8)
        selector.unselectedColor = UIColor(red: 77/255, green: 196/255, blue: 95/255, alpha: 0.8)
        selector.selectedTextColor = UIColor(white: 1, alpha: 1)
        selector.selectedColor = UIColor(red: 67/255, green: 198/255, blue: 88/255, alpha: 1)
    }
    
}