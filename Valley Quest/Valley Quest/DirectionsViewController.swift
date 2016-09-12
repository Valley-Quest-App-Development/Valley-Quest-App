//
//  DirectionsViewController.swift
//  Valley Quest App
//
//  Created by John Kotz on 3/20/16.
//  Copyright © 2016 vitalCommunities. All rights reserved.
//

import Foundation
import MapKit

class DirectionsViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UITextView!
    @IBOutlet weak var missingLocationLabel: UILabel!
    
    var quest: Quest!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        descriptionLabel.text = quest.Description
        titleLabel.text = quest.Name
        
        if let gps = quest.start?.coordinate {
            let annotation = MKPointAnnotation()
            annotation.coordinate = gps
            
            self.mapView.addAnnotation(annotation)
        }
        
        updateMapPermissions()
    }
    
    func updateMapPermissions() {
        missingLocationLabel.hidden = quest.hasGPS()
        self.mapView.userInteractionEnabled = quest.hasPDF()
    }
    
    func processName(string: String) -> String {
        var output = string.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        if (!output.lowercaseString.containsString("quest")) {
            output += " Quest"
        }
        
        return output
    }
    
    @IBAction func mapKitTouched(sender: AnyObject) {
        if let data = quest.start?.coordinate {
            let coordinate = CLLocationCoordinate2D(latitude: data.latitude, longitude: data.longitude)
            let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
            mapItem.name = processName(quest.Name) + " Start"
            mapItem.openInMapsWithLaunchOptions([MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
        }
    }
}