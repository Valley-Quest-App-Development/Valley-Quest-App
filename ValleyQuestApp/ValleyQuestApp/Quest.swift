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
    
    // ----------------------------
    // Initialization methods
    // ----------------------------
    
    
    func addToSpotlight() {
        let atributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeText as String)
        atributeSet.title = self.Name
        atributeSet.contentDescription = self.Description
        
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
     Parses the given PFObjects into quest objects
    */
    class func getQuestsFromPFOBjects(objects: [PFObject]) -> Array<Quest> {
        var array = [Quest]()
        
        for quest in objects {
            if let quest = quest as? Quest {
                array.append(quest)
                quest.addToSpotlight()
            }
        }
        
        return array
    }
    
    static func sortQuests(inout quests: Array<Quest>) {
        quests.sortInPlace { (quest1, quest2) -> Bool in
            return quest1.Name < quest2.Name
        }
    }
    
    // Quicksort
    
    private static func quickSort(inout array: Array<Quest>, start: Int, end: Int) {
        if (start >= end) {
            return;
        }
        
        let part = partition(&array, start: start, end: end)
        
        quickSort(&array, start: start, end: part - 1)
        quickSort(&array, start: part + 1, end: end)
    }
    
    private static func partition(inout array: Array<Quest>, start: Int, end: Int) -> Int {
        let compareValue = array[end]
        var under = start
        var positon = start
        
        while (positon < end) {
            if (compareValue.Name > array[positon].Name) {
                swap(&array, a: positon, b: under)
                under += 1
            }
            positon += 1
        }
        
        swap(&array, a: end, b: under)
        return under;
    }
    
    private static func swap(inout array: Array<Quest>, a: Int, b: Int) {
        let holder = array[a]
        array[a] = array[b]
        array[b] = holder
    }
    
    // End Quicksort
}