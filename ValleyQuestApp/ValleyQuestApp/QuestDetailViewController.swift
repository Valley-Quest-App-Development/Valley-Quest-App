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
    let regionRadius: CLLocationDistance = 1000
    
    override func viewDidLoad() {
        let initialLocation = CLLocation(latitude: 43.702222, longitude: -72.289444)
        centerOnLocation(initialLocation)
//        mapView.hidden = true;
        
        if let quest = object {
            durationAndDifficulty.text = "Duration: " + quest.duration + " Difficulty: " + quest.difficulty
            descriptionLabel.text = quest.description
            self.title = quest.title
        }
        descriptionLabel.setContentOffset(CGPoint.zero, animated: false)
    }
    
    @IBAction func share(sender: AnyObject) {
        
    }
    
    @IBAction func startQuest(sender: UIButton) {
        
    }
    
    @IBAction func showMoreInfo(sender: AnyObject) {
        
    }
    
    @IBAction func showClues(sender: AnyObject) {
        
    }
    
    func centerOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func setQuestObject(object: Quest) {
        self.object = object
    }
}