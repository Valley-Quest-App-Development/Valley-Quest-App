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
    
    /*
    Loads the quests into a Dictionary. If it can't find it or if it is in the wrong format, it will return nil. Thus it is an optional return method
    
    Dictionary format:
    Key: A string of the quest ID (e.g. "Quest1")
    Value: Dictionary for that quest:
        Key: A string of the name some atribute of the quest
        Value: A string of that atribute
    */
    func getQuests() -> Dictionary<String, Dictionary<String, String>>? {
        if let fileName = questsPath {
            if (NSFileManager.defaultManager().fileExistsAtPath(fileName)) {
                // File name exists and the file exists
                // Load the file, and convert it
                let questDictionary = NSMutableDictionary(contentsOfFile: fileName)!
                return convertDictionaries(questDictionary)
            }
        }
        // The file was wrong!
        return nil
    }
    
    /*
    Converts the given NSMutableDictionary into the quest specific Dictionary type
    If it is not in that format, then it will throw an error!
    */
    private func convertDictionaries(dictionary: NSMutableDictionary) -> Dictionary<String, Dictionary<String, String>>? {
        // Creates a dictionary that we will put the data into
        var newDict: Dictionary<String, Dictionary<String, String>> = Dictionary()
        // Iterate through the dictionary
        for (key, value) in dictionary {
            // This makes sure that the key is a string
            if let keyChecked = key as? String {
                
                // Since it is another dictionary, do it for just that one
                var subDict: Dictionary<String, String> = Dictionary()
                if let dictValue = value as? NSMutableDictionary {
                    for (subKey, subValue) in dictValue {
                        // For most of these, I didn't bother to check if they were strings, so if it is in the wrong format, it will throw an error
                        if let checkedSubKey = subKey as? String {
                            if let checkedSubValue = subValue as? String {
                                subDict[checkedSubKey] = checkedSubValue
                            }else{
                                return nil
                            }
                        }else{
                            return nil
                        }
                    }
                    // Now store that dictionary in the over all dictionary
                    newDict[keyChecked] = subDict
                }else{
                    return nil
                }
            }else{
                return nil
            }
        }
        return newDict
    }
}