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
        
        if let quest = object {
            mapView.hidden = !quest.hasGPS()
            if (quest.hasGPS()) {
                // Drop a pin
                let dropPin = MKPointAnnotation()
                dropPin.coordinate = quest.getGPS()!.coordinate
                dropPin.title = "Start of " + quest.title
                mapView.addAnnotation(dropPin)
                
                centerOnLocation(quest.getGPS()!)
            }
            
            // If the clues are empty, don't show the clues button
            if quest.clues.count == 0 {
                cluesButton.hidden = true
            }
            
            // Set the text for the duration and such
            durationAndDifficulty.text = "Duration: " + quest.duration + " Difficulty: " + quest.difficulty
            if quest.description == "" {
                // Missing description!!
                descriptionLabel.text = "There is no description listed for this quest"
            }else{
                // Set description
                descriptionLabel.text = quest.description
            }
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let viewController = segue.destinationViewController as? CluesViewController {
            viewController.setObject(object!)
        }
    }
    
    @IBAction func showClues(sender: AnyObject) {
        self.performSegueWithIdentifier("showClues", sender: nil)
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