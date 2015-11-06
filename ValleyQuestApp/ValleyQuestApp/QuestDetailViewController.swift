//
//  QuestDetailViewController.swift
//  ValleyQuestApp
//
//  Created by Seb Lim on 10/28/15.
//  Copyright © 2015 John Kotz. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class QuestDetailViewController: UIViewController {
    @IBOutlet weak var descriptionLabel: UITextView!
    @IBOutlet weak var durationAndDifficulty: UILabel!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var cluesButton: UIButton!
    @IBOutlet var mapView: MKMapView!
    
    var object: Quest? = nil
    
    override func viewDidLoad() {
        if let quest = object {
            durationAndDifficulty.text = "Duration: " + quest.duration + " Difficulty: " + quest.difficulty
            descriptionLabel.text = quest.description
            self.title = quest.title
        }
        descriptionLabel.setContentOffset(CGPoint.zero, animated: false)
    }
    
    func setQuestObject(object: Quest) {
        self.object = object
    }
}