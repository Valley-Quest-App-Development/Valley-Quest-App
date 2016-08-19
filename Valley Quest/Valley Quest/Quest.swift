//
//  Quests.swift
//  ValleyQuestApp
//
//  Created by John Kotz on 10/27/15.
//  Copyright © 2015 Valley Quest App Dev. All rights reserved.
//

import Foundation
import CoreSpotlight
import MobileCoreServices
import MapKit
import Parse


extension Array {
    // Does a shallow copy of the array
    func copy() -> Array {
        var newArray:Array = []
        for value in self {
            newArray.append(value)
        }
        return newArray
    }
}

class Quest: PFObject, PFSubclassing {
    // ---------------------------
    // Data and storage variables
    // ---------------------------
    
    @NSManaged var Name: String
    @NSManaged var Clues: [String]?
    @NSManaged var Season: String
    @NSManaged var SpecialFeatures: String
    @NSManaged var Location: String
    @NSManaged var GPS: PFGeoPoint?
    @NSManaged var Bring: String?
    @NSManaged var Description: String
    @NSManaged var Difficulty: String
    @NSManaged var WalkingConditions: String
    @NSManaged var pdf: PFFile?
    @NSManaged var Directions: String
    @NSManaged var cluesLocation: String?
    @NSManaged var overview: String?
    @NSManaged var book: String?
    @NSManaged var Correction: String?
    @NSManaged var duration: NSNumber?
    @NSManaged var gps_loc: PFGeoPoint?
    @NSManaged var gps_end: String?
    
    var start: CLLocation?
    var end: CLLocation?
    
    // ----------------------------
    // Initialization methods
    // ----------------------------
    
    
    func addToSpotlight() {
        let atributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeText as String)
        atributeSet.title = self.Name
        
        var value = self.Description
        
        if let overview = self.overview where value == "" {
            value = overview
        }
        
        atributeSet.contentDescription = value
        
        if let location = self.cluesLocation {
            if location.lowercaseString.containsString("closed") {
                atributeSet.contentDescription = "Closed"
            }
        }
        atributeSet.namedLocation = self.Location
        
        let searchItem = CSSearchableItem(uniqueIdentifier: "\(self.objectId!)", domainIdentifier: "com.vitalcommunities.ValleyQuest", attributeSet: atributeSet)
        CSSearchableIndex.defaultSearchableIndex().indexSearchableItems([searchItem], completionHandler: { (error: NSError?) -> Void in
            if error != nil {
                print(error?.localizedDescription)
            }
        })
    }
    
    func hasGPS() -> Bool {
        return self.GPS != nil
    }
    
    func hasClues() -> Bool {
        return self.Clues != nil && self.Clues?.count != 0
    }
    
    func hasPDF() -> Bool {
        return self.pdf != nil
    }
    
    func isClosed() -> Bool {
        return (self.cluesLocation != nil && self.cluesLocation!.lowercaseString.containsString("closed")) || (self.Correction != nil && self.Correction!.lowercaseString.containsString("closed"))
    }
    
//    func getSource() -> String? {
//        if let location = self.cluesLocation {
//            if location.containsString(".pdf") {
//                return nil
//            }
//        }
//        
//        return self.cluesLocation
//    }
    
    // ---------------------------
    // Static methods
    // ---------------------------
    
    
    static func parseClassName() -> String {
        return "Quests"
    }
    
    /**
     Parses the given PFObjects into quest objects, and returns a tuple. The second object is a boolean that indicates if there are quests with gps
    */
    class func getQuestsFromPFOBjects(objects: [PFObject]) -> (Array<Quest>, Bool) {
        var array = [Quest]()
        var foundGPS = false
        
        for quest in objects {
            if let quest = quest as? Quest {
                array.append(quest)
                quest.addToSpotlight()
                if let loc = quest.gps_loc {
                    quest.start = CLLocation(latitude: loc.latitude, longitude: loc.longitude);
                    if let end = quest.gps_end {
                        // TODO: deal with a string :(
                    }
                    foundGPS = true
                }
            }
        }
        
        return (array, foundGPS)
    }
    
    static func sortQuests(inout quests: Array<Quest>) {
        quests.sortInPlace { (quest1, quest2) -> Bool in
            return quest1.Name < quest2.Name
        }
    }
}