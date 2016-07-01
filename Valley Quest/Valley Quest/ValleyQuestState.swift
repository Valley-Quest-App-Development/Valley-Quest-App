//
//  ValleyQuestState.swift
//  Valley Quest
//
//  Created by John Kotz on 6/28/16.
//  Copyright © 2016 Valley Quest. All rights reserved.
//

import Foundation
import Parse
import Crashlytics

extension NSDate {
    func yearsFrom(date: NSDate) -> Int {
        return NSCalendar.currentCalendar().components(.Year, fromDate: date, toDate: self, options: []).year
    }
    func monthsFrom(date: NSDate) -> Int {
        return NSCalendar.currentCalendar().components(.Month, fromDate: date, toDate: self, options: []).month
    }
    func weeksFrom(date: NSDate) -> Int {
        return NSCalendar.currentCalendar().components(.WeekOfYear, fromDate: date, toDate: self, options: []).weekOfYear
    }
    func daysFrom(date: NSDate) -> Int {
        return NSCalendar.currentCalendar().components(.Day, fromDate: date, toDate: self, options: []).day
    }
    func hoursFrom(date: NSDate) -> Int {
        return NSCalendar.currentCalendar().components(.Hour, fromDate: date, toDate: self, options: []).hour
    }
    func minutesFrom(date: NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.Minute, fromDate: date, toDate: self, options: []).minute
    }
    func secondsFrom(date: NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.Second, fromDate: date, toDate: self, options: []).second
    }
    func offsetFrom(date: NSDate) -> String {
        if yearsFrom(date)   > 0 { return "\(yearsFrom(date))y"   }
        if monthsFrom(date)  > 0 { return "\(monthsFrom(date))M"  }
        if weeksFrom(date)   > 0 { return "\(weeksFrom(date))w"   }
        if daysFrom(date)    > 0 { return "\(daysFrom(date))d"    }
        if hoursFrom(date)   > 0 { return "\(hoursFrom(date))h"   }
        if minutesFrom(date) > 0 { return "\(minutesFrom(date))m" }
        if secondsFrom(date) > 0 { return "\(secondsFrom(date))s" }
        return ""
    }
}

class State {
    static private let defaults = NSUserDefaults.standardUserDefaults()
    static private var questInProgressStored: Quest?
    static private var questPinnedBefore = false
    static private var startTime: NSDate?
    
    
    static var questInProgress: Quest? {
        get {
            if let questInProgressStored = questInProgressStored {
                return questInProgressStored
            }
            
            if let objID = defaults.objectForKey("questInProgress") as? String {
                let object = PFObject(withoutDataWithClassName: Quest.parseClassName(), objectId: objID)
                
                object.fetchInBackground()
                return object as? Quest
            }
            return nil
        }
        set {
            // If it wasnt already saved before we started, then we should unsave it
            if let prevQuest = questInProgress where !questPinnedBefore {
                prevQuest.unpinInBackground()
            }
            questPinnedBefore = false
            
            // Set the value
            questInProgressStored = newValue
            defaults.setObject(newValue?.objectId, forKey: "questInProgress")
            
            // Check to see if it is a new quest
            if let _ = newValue {
                startTime = NSDate()
            }
            
            // I need to check to see if it is already saved
            if let newValue = newValue {
                let query = PFQuery(className: Quest.parseClassName())
                query.fromLocalDatastore()
                query.findObjectsInBackgroundWithBlock { (objects, error) in
                    if let objects = objects as? [Quest] where error == nil {
                        for object in objects {
                            if object.objectId == newValue.objectId {
                                // The new value is in the local datastore! So we shouldn't unsave it when we are done
                                
                                questPinnedBefore = true
                                break
                            }
                        }
                    }
                    
                    // No matter what, I need to pin it
                    newValue.pinInBackground()
                }
            }
        }
    }
    
    static func loadQuestInProgress(callback: ((Quest?, NSError?)->Void)?) {
        if let objID = defaults.objectForKey("questInProgress") as? String {
            let object = PFObject(withoutDataWithClassName: Quest.parseClassName(), objectId: objID)
            object.fetchInBackgroundWithBlock({ (object, error) in
                if let callback = callback {
                    callback(object as? Quest, error)
                }
            })
        }else{
            if let callback = callback {
                callback(nil, nil)
            }
        }
    }
    
    static func finishQuest() {
        if let quest = questInProgress {
            var atributes: [String:AnyObject] = ["name":quest.Name]
            if let start = startTime {
                let minutes = NSDate().minutesFrom(start)
                atributes["duration"] = minutes
            }
            
            
            Answers.logCustomEventWithName("Finished quest", customAttributes: atributes)
            questInProgress = nil
            startTime = nil
        }
    }
}