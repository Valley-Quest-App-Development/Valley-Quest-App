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
        private var value: String
        private var query: String
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
        
        func loadBuildings(callback: (NSError?) -> Void) {
            let query = MapBuildings.query()!
            query.limit = 1000
            
            completeQuery(query, callback: callback)
        }
        
        func getSearchQuery() -> PFQuery {
            let query = MapBuildings.query()!
            query.limit = 1000
            query.whereKey("name", containsString: self.query)
            
            return query
        }
        
        func search(callback: (NSError?) -> Void) {
            if self.query == "" && self.query.characters.count < 8 {
                callback(NSError(domain: "MapBuildings", code: 300, userInfo: ["message": "You must have a query!"]))
            }
            
            completeQuery(getSearchQuery(), callback: callback);
        }
        
        private func completeQuery(query: PFQuery, callback: (error: NSError?) -> Void) {
            query.findObjectsInBackgroundWithBlock { (objects, error) in
                if let buildings = objects as? [MapBuildings] where error == nil {
                    self.buildings = buildings
                    callback(error: nil)
                }else{
                    callback(error: error)
                }
            }
        }
        
        func removeAllBuildings(callback: (done: Bool, error: NSError?) -> Void, progress: (Int) -> Void)  {
            var left = self.buildings.count
            for building in buildings {
                building.deleteInBackgroundWithBlock({ (success, error) in
                    if !success {
                        callback(done: false, error: NSError(domain: "MapBuildings", code: 500, userInfo: ["message": "Failed to delete an object"]))
                    }
                    
                    if error != nil {
                        callback(done: false, error: error)
                    }
                    
                    left -= 1;
                    progress(self.buildings.count - left);
                    
                    if left <= 0 {
                        callback(done: true, error: nil)
                    }
                })
            }
        }
    }
    
    class QuestMod {
        private var value: String
        private var query: String
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
        
        func loadQuests(callback: (error: NSError?) -> Void) {
            let query = Quest.query()!
            query.limit = 1000
            
            completeQuery(query, callback: callback)
        }
        
        func splitQuestsWithSeperator(seperator: Character) {
            givenQuestNames = self.value.characters.split{$0 == seperator}.map(String.init)
        }
        
        private func completeQuery(query: PFQuery, callback: (error: NSError?) -> Void) {
            query.findObjectsInBackgroundWithBlock { (objects, error) in
                if let quests = objects as? [Quest] where error == nil {
                    self.quests = quests
                    callback(error: nil)
                }else{
                    callback(error: error)
                }
            }
        }
        
        func getSearchQuery() -> PFQuery {
            let query = Quest.query()!
            query.limit = 1000
            query.addAscendingOrder(self.value)
            query.whereKey(self.value, containsString: self.query)
            
            return query
        }
        
        func search(callback: (error: NSError?) -> Void) {
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
        func saveAll(callback: (error: NSError?) -> Void, progress: (Int) -> Void) -> Int {
            var left = quests.count
            var failed = 0
            
            for quest in quests {
                quest.saveInBackgroundWithBlock({ (success, error) in
                    left -= 1
                    
                    progress(self.quests.count - left);
                    
                    if let error = error {
                        if !success {
                            failed += 1
                            
                            if failed >= self.quests.count / 3 {
                                callback(error: error)
                                return
                            }
                            
                        }
                        print("\(error) - success? \(success)")
                    }
                    
                    
                    if left <= 0 {
                        callback(error: nil)
                    }
                })
            }
            
            return quests.count
        }
    }
}