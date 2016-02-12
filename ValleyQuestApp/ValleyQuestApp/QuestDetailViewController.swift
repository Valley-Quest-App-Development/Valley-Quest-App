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
import Parse

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
                dropPin.coordinate = CLLocationCoordinate2D(latitude: quest.GPS!.latitude, longitude: quest.GPS!.longitude)
                dropPin.title = "Start of " + quest.Name
                mapView.addAnnotation(dropPin)
                
                
                centerOnLocation(CLLocation(latitude: quest.GPS!.latitude, longitude: quest.GPS!.longitude))
                let location = CLLocationManager()
                location.requestWhenInUseAuthorization()
            }
            
            // If the clues are empty, don't show the clues button
            if quest.Clues == nil || quest.Clues!.count == 0 {
                cluesButton.hidden = true
            }
            
            self.moreButton.hidden = true
            
            // Set the text for the duration and such
            durationAndDifficulty.text = "Difficulty: " + quest.Difficulty
            if quest.description == "" {
                // Missing description!!
                descriptionLabel.text = "There is no description listed for this quest"
            }else{
                // Set description
                descriptionLabel.text = quest.Description
            }
            self.title = quest.Name
        }
        descriptionLabel.setContentOffset(CGPoint.zero, animated: false)
    }
    
    override func previewActionItems() -> [UIPreviewActionItem] {
        let saveQuest = UIPreviewAction(title: "Save", style: UIPreviewActionStyle.Default) { (action, viewController) -> Void in
            print("Need to save a quest!")
        }
        
        let share = UIPreviewAction(title: "Share", style: UIPreviewActionStyle.Default) { (action, viewController) -> Void in
            print("Need to share a quest!")
        }
        
        return [saveQuest, share]
    }
    
    @IBAction func share(sender: UIBarButtonItem) {
        if let quest = object {
            let textToShare = "Check out the quest " + quest.Name + " in the Valley Quest app\n"
            if let url = NSURL(string: "http://appstore.com/valleyquest") {
                
                let activity: UIActivityViewController = UIActivityViewController(activityItems: [textToShare, url, quest], applicationActivities: nil)
                activity.excludedActivityTypes = [UIActivityTypeAddToReadingList]
                
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.Pad) {
                    activity.modalPresentationStyle = UIModalPresentationStyle.Popover
                    activity.popoverPresentationController!.barButtonItem = sender
                }
                
                
                self.presentViewController(activity, animated: true, completion: nil)
            }
            
        }
        
        
    }
    
    @IBAction func startQuest(sender: UIButton) {
        if let quest = object, let clues = quest.Clues {
            self.performSegueWithIdentifier("showClues", sender: clues)
        }else if let quest = object, let pdf = quest.pdf {
            self.performSegueWithIdentifier("showPDF", sender: pdf)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let viewController = segue.destinationViewController as? CluesViewController {
            viewController.set(object!)
        }
        
        if let destination = segue.destinationViewController as? PDFViewController {
            destination.setObject(sender as! PFFile)
            if let quest = object {
                if quest.hasGPS() {
                    destination.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Go there", style: UIBarButtonItemStyle.Plain, target: self, action: "openLocation")
                }
            }
        }
    }
    
    func openLocation() {
        if let quest = object, let gps = quest.GPS {
            let regionDistance:CLLocationDistance = regionRadius * 50.0
            let coordinates = CLLocationCoordinate2DMake(gps.latitude, gps.longitude)
            let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
            let options = [
                MKLaunchOptionsMapCenterKey: NSValue(MKCoordinate: regionSpan.center),
                MKLaunchOptionsMapSpanKey: NSValue(MKCoordinateSpan: regionSpan.span)
            ]
            
            let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = "\(quest.Name) start"
            mapItem.openInMapsWithLaunchOptions(options)
        }
    }
    
    @IBAction func showClues(sender: AnyObject) {
        self.performSegueWithIdentifier("showClues", sender: nil)
    }
    
    func centerOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 50.0, regionRadius * 50.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func setQuestObject(object: Quest) {
        self.object = object
    }
}