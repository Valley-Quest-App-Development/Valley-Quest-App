//
//  Modifier.swift
//  Parse Modifier
//
//  Created by John Kotz on 8/22/16.
//  Copyright © 2016 John Kotz. All rights reserved.
//

import Foundation
import Parse


class Modifier {
    class BookUpModifyer {
        fileprivate var value: String
        fileprivate var query: String
        var buildings: [MapBuildings]
        
        init(value: String) {
            self.value = value
            self.buildings = []
            self.query = ""
        }
        
        init(value: String, query: String) {
            self.value = value
            self.buildings = []
            self.query = query
        }
        
        func loadBuildings(_ callback: @escaping (NSError?) -> Void) {
            let query = MapBuildings.query()!
            query.limit = 1000
            
            completeQuery(query, callback: callback)
        }
        
        func getSearchQuery() -> PFQuery<PFObject> {
            let query = MapBuildings.query()!
            query.limit = 1000
            query.whereKey("name", contains: self.query)
            
            return query
        }
        
        func search(_ callback: @escaping (NSError?) -> Void) {
            if self.query == "" && self.query.characters.count < 8 {
                callback(NSError(domain: "MapBuildings", code: 300, userInfo: ["message": "You must have a query!"]))
            }
            
            completeQuery(getSearchQuery(), callback: callback);
        }
        
        fileprivate func completeQuery(_ query: PFQuery<PFObject>, callback: @escaping (_ error: NSError?) -> Void) {
            query.findObjectsInBackground { (objects, error) in
                if let buildings = objects as? [MapBuildings] , error == nil {
                    self.buildings = buildings
                    callback(nil)
                }else{
                    callback(error as NSError?)
                }
            }
        }
        
        func removeAllBuildings(_ callback: @escaping (_ done: Bool, _ error: NSError?) -> Void, progress: @escaping (Int) -> Void)  {
            var left = self.buildings.count
            for building in buildings {
                building.deleteInBackground(block: { (success, error) in
                    if !success {
                        callback(false, NSError(domain: "MapBuildings", code: 500, userInfo: ["message": "Failed to delete an object"]))
                    }
                    
                    if error != nil {
                        callback(false, error as NSError?)
                    }
                    
                    left -= 1;
                    progress(self.buildings.count - left);
                    
                    if left <= 0 {
                        callback(true, nil)
                    }
                })
            }
        }
        
        func tryRemoveItem(_ progress: @escaping (_ string: String) -> Void, _ complete: @escaping (_ success: Bool) -> Void) {
            let query = PFQuery(className: "studyGroup")
            query.whereKey("isClassGroup", equalTo: true)
            var successful = true
            
            query.getFirstObjectInBackground { (object, error) in
                object?.deleteInBackground(block: { (success, error) in
                    progress(success ? "Deleted the object!" : "Couldn't delete the object")
                    successful = !success
                    if let error = error {
                        progress(error.localizedDescription)
                        successful = error.localizedDescription == "Can't delete class groups!"
                    }
                    
                    PFObject(withoutDataWithClassName: "studyGroup", objectId: object?.objectId).fetchInBackground(block: { (object, error) in
                        if object == nil && error != nil {
                            successful = false
                        }else{
                            successful = true && successful
                        }
                        
                        
                        
                        object?.saveInBackground(block: { (success, error) in
                            progress(success ? "Re-saved the object" : "Failed to save!")
                            if let error = error {
                                progress("Error: " + error.localizedDescription)
                            }
                            complete(successful)
                        })
                        
                        if object == nil {
                            complete(successful)
                        }
                    })
                })
            }
        }
    }
    
    class QuestMod {
        fileprivate var value: String
        fileprivate var query: String
        var quests: [Quest]
        var givenQuestNames = [String]()
        
        init(value: String) {
            self.value = value
            quests = []
            self.query = ""
        }
        
        init(value: String, query: String) {
            self.value = value
            quests = []
            self.query = query
        }
        
        func loadQuests(_ callback: @escaping (_ error: NSError?) -> Void) {
            let query = Quest.query()!
            query.limit = 1000
            
            completeQuery(query, callback: callback)
        }
        
        func splitQuestsWithSeperator(_ seperator: Character) {
            givenQuestNames = self.value.characters.split{$0 == seperator}.map(String.init)
        }
        
        fileprivate func completeQuery(_ query: PFQuery<PFObject>, callback: @escaping (_ error: NSError?) -> Void) {
            query.findObjectsInBackground { (objects, error) in
                if let quests = objects as? [Quest] , error == nil {
                    self.quests = quests
                    callback(nil)
                }else{
                    callback(error as NSError?)
                }
            }
        }
        
        func getSearchQuery() -> PFQuery<PFObject> {
            let query = Quest.query()!
            query.limit = 1000
            query.addAscendingOrder(self.value)
            query.whereKey(self.value, contains: self.query)
            
            return query
        }
        
        func search(_ callback: @escaping (_ error: NSError?) -> Void) {
            completeQuery(getSearchQuery(), callback: callback)
        }
        
        func compileClosed() {
            for quest in quests {
                quest.closed = quest.isClosed()
            }
        }
        
        func getQuestsNeedingPDF() -> [Quest] {
            var quests = [Quest]()
            
            for quest in self.quests {
                if (!quest.hasPDF() && !quest.isClosed()) {
                    quests.append(quest)
                }
            }
            
            return quests
        }
        
        // Returns max progress
        func saveAll(_ callback: @escaping (_ error: NSError?) -> Void, progress: @escaping (Int) -> Void) {
            var left = quests.count
            var failed = 0
            
            for quest in quests {
                quest.saveInBackground(block: { (success, error) in
                    left -= 1
                    
                    progress(self.quests.count - left);
                    
                    if let error = error {
                        if !success {
                            failed += 1
                            
                            if failed >= self.quests.count / 3 {
                                callback(error as NSError?)
                                return
                            }
                            
                        }
                        print("\(error) - success? \(success)")
                    }
                    
                    
                    if left <= 0 {
                        callback(nil)
                    }
                })
            }
        }
    }
    
    class QuestGPSMod {
        var values: [Quest.QuestGPSSet] = []
        var validLocs: Dictionary<String, (start: CLLocation, end: CLLocation)> = [:]
        
        func loadValues(_ callback: @escaping (_ error: Error?) -> Void) {
            let query = Quest.QuestGPSSet.query()
            
            query?.findObjectsInBackground(block: { (objects, error) in
                if let objects = objects as? [Quest.QuestGPSSet] {
                    self.values = objects
                }
                callback(error)
            })
        }
        
        func processValues(_ callback: @escaping (_ error: NSError?) -> Void, progress: @escaping (Int) -> Void) {
            
            DispatchQueue.global(qos: .background).async {
                var dict: Dictionary<String, (start: [CLLocation], end: [CLLocation])> = [:]
                
                for set in self.values {
                    let loc = CLLocation(latitude: set.point.latitude, longitude: set.point.longitude)
                    let value = dict[set.quest.objectId!]
                    
                    if set.placeType == "start" {
                        if let value = value {
                            var start = value.start
                            start.append(loc)
                        }else{
                            dict[set.quest.objectId!] = ([loc], [])
                        }
                    }else{
                        // Its end
                        if value != nil {
                            
                        }else{
                            dict[set.quest.objectId!] = ([], [loc])
                        }
                    }
                    
                    //
                }
                
                DispatchQueue.main.async {
                    callback(nil)
                }
            }
        }
    }
}
