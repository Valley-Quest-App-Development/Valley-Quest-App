//
//  Quests.swift
//  ValleyQuestApp
//
//  Created by John Kotz on 10/27/15.
//  Copyright © 2015 Valley Quest App Dev. All rights reserved.
//

import Foundation
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
    
    var closed: Bool {
        get { return self["closed"] as! Bool }
        set { self["closed"] = newValue }
    }
    
    var start: CLLocation? {
        get {
            if let loc = gps_loc {
                return CLLocation(latitude: loc.latitude, longitude: loc.longitude);
            }else{
                return nil
            }
        }
        set {}
    }
    var end: CLLocation?
    
    // ----------------------------
    // Initialization methods
    // ----------------------------
    
    func hasGPS() -> Bool {
        return self.gps_loc != nil
    }
    
    func hasClues() -> Bool {
        return self.Clues != nil && self.Clues?.count != 0
    }
    
    func hasPDF() -> Bool {
        return self.pdf != nil
    }
    
    func isClosed() -> Bool {
        return (self.cluesLocation != nil && self.cluesLocation!.lowercaseString.containsString("closed")) || (self.Correction != nil && self.Correction!.lowercaseString.containsString("closed")) || self.closed
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
    class func getQuestsFromPFOBjects(objects: [PFObject]) -> Array<Quest> {
        var array = [Quest]()
        
        if let newArray = objects as? [Quest] {
            array = newArray
        }
        
        return array
    }
    
    static func sortQuests(inout quests: Array<Quest>) {
        quests.sortInPlace { (quest1, quest2) -> Bool in
            return quest1.Name < quest2.Name
        }
    }
    
    static func getNames(array: [Quest]) -> Array<String> {
        var output: Array<String> = []
        
        for quest in array {
            output.append(quest.Name)
        }
        
        return output
    }
    
    static func getNamesString(array: [Quest], separator: String) -> String {
        var output = ""
        
        for quest in array {
            output += "\(quest.Name)\(separator)"
        }
        
        return output
    }
    
    static func getNamesAndLocs(array: [Quest]) -> Array<(String, String)> {
        var output: Array<(String, String)> = []
        
        for quest in array {
            output.append((quest.Name, quest.Location))
        }
        
        return output
    }
    
    static func getNamesAndLocsString(array: [Quest], separator: String) -> String {
        var output = ""
        
        for quest in array {
            output += "\(quest.Name) - \(quest.Location)\(separator)"
        }
        
        return output
    }
}