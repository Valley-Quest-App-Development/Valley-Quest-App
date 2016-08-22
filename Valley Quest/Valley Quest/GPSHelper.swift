//
//  GPSHelper.swift
//  Valley Quest
//
//  Created by John Kotz on 7/11/16.
//  Copyright © 2016 Valley Quest. All rights reserved.
//

import Foundation
import Parse
import CoreLocation

class LocationController: NSObject, CLLocationManagerDelegate {
    enum Method {
        case Single
        case Multi
    }
    
    class Distance {
        private var distanceInMeters: CLLocationDistance
        
        init(distance: CLLocationDistance) {
            self.distanceInMeters = distance
        }
        
        var meters: Double {
            set {self.distanceInMeters = newValue}
            get {return self.distanceInMeters}
        }
        var feet: Double {
            set {self.distanceInMeters = newValue / 3.28084}
            get {return self.distanceInMeters * 3.28084}
        }
        var miles: Double {
            set {self.distanceInMeters = newValue * 1609.34}
            get {return self.distanceInMeters / 1609.34}
        }
        var kilometers: Double {
            set {self.distanceInMeters = newValue * 1000.0}
            get {return distanceInMeters / 1000.0}
        }
        var yard: Double {
            set {distanceInMeters = newValue / 1.09361}
            get {return distanceInMeters * 1.09361}
        }
        var nauticalMile: Double {
            set {distanceInMeters = newValue * 1852}
            get {return distanceInMeters / 1852}
        }
    }

    var locationManager = CLLocationManager()
    var authStatus: CLAuthorizationStatus = .NotDetermined
    var locationAquired: ((CLLocation) -> Void)?
    var method: Method = .Multi
    var answeredCallback: (() -> Void)?
    
    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }
    
    init(answeredCallback: ()->Void) {
        super.init()
        self.answeredCallback = answeredCallback
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        self.authStatus = status
        if let answeredCallback = answeredCallback {
            answeredCallback()
        }
    }
    
    func getOneLocation(callback: ((CLLocation) -> Void)?) {
        self.locationAquired = callback
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        self.method = .Single
    }
    
    // Returns the distance in (meters, miles)
    func calculateDistance(start: CLLocation, end: CLLocation) -> Distance {
        let meters: CLLocationDistance = end.distanceFromLocation(start)
        
        return Distance(distance: meters)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location: CLLocation = locations.last, let locationAquired = locationAquired {
            locationAquired(location)
        }
        if method == .Single {
            manager.stopUpdatingLocation()
            locationManager.stopUpdatingLocation()
            locationAquired = nil
        }
    }
}

class QuestGPSSet: PFObject, PFSubclassing {
    @NSManaged var point: PFGeoPoint
    @NSManaged var placeType: Type.RawValue
    @NSManaged var quest: Quest
    var type: Type {
        set {
            placeType = newValue.rawValue
        }
        get {
            if let newType = Type(rawValue: placeType) {
                return newType
            }else{
                return .None
            }
        }
    }
    
    enum Type: String {
        case Start = "start"
        case End = "end"
        case Box = "box"
        case None = ""
    }
    
    static func create(point: CLLocation, type: Type) -> QuestGPSSet {
        let new = QuestGPSSet()
        new.point = PFGeoPoint(latitude: point.coordinate.latitude, longitude: point.coordinate.longitude)
        new.type = type
        return new
    }
    
    func addStart(start: CLLocation) {
        self.point = PFGeoPoint(latitude: start.coordinate.latitude, longitude: start.coordinate.longitude)
        self.type = .Start
        self.saveEventually { (success, error) in
            if success {
                let relation = self.quest.relationForKey("GPSData")
                relation.addObject(self)
                self.quest.saveEventually()
            }
        }
    }
    
    func addEnd(end: CLLocation) {
        self.point = PFGeoPoint(latitude: end.coordinate.latitude, longitude: end.coordinate.longitude)
        self.type = .End
        self.saveEventually { (success, error) in
            if success {
                let relation = self.quest.relationForKey("GPSData")
                relation.addObject(self)
                self.quest.saveEventually()
            }
        }
    }
    
    static func parseClassName() -> String {
        return "QuestGPSSet"
    }
}