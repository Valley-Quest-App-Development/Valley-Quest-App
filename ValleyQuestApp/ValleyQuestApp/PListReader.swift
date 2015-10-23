//
//  PListReader.swift
//  ValleyQuestApp
//
//  Created by John Kotz on 10/18/15.
//  Copyright © 2015 John Kotz. All rights reserved.
//

import Foundation

class PListReader {
    var questsPath: String? = ""
    
    init() {
        questsPath = NSBundle.mainBundle().pathForResource("quests", ofType: "plist")
    }
    
    func getQuests() -> Dictionary<String, Dictionary<String, String>>? {
        if let fileName = questsPath {
            if (NSFileManager.defaultManager().fileExistsAtPath(fileName)) {
                let questDictionary = NSMutableDictionary(contentsOfFile: fileName)
                return convertDictionaries(questDictionary)
            }
        }
        return nil
    }
    
    private func convertDictionaries(dictionary: NSMutableDictionary) -> Dictionary {
        
    }
}