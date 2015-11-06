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

class Quest {
    // ---------------------------
    // Data and storage variables
    // ---------------------------
    
    // Identification values
    let id: String
    let title: String
    
    // Info values
    let duration: String
    let description: String
    let location: String
    let difficulty: String
    let walkingConditions: String
    let specialFeatures: String
    let season: String
    let bring: String
    var clues: Array<String>
    
    
    // ----------------------------
    // Initialization methods
    // ----------------------------
    
    /*
        This takes the id and the dictionary it's data is stored in and loads it all
    */
    init(id: String, dict: Dictionary<String, String>) {
        // Store the id and initialize the clues
        self.id = id
        self.clues = []
        
        // Get the rest of the data
        if let titleChecked = dict["Title"] {title = titleChecked} else {title = ""}
        
        if let durationChecked = dict["Duration"] {duration = durationChecked} else {duration = ""}
        
        if let descriptionChecked = dict["Description"] {description = descriptionChecked} else {description = ""}
        
        if let locationChecked = dict["Location"] {location = locationChecked} else {location = ""}
        
        if let difficultyChecked = dict["Difficulty"] {difficulty = difficultyChecked} else {difficulty = ""}
        
        if let walkingConditionsChecked = dict["Walking Conditions"] {walkingConditions = walkingConditionsChecked} else {walkingConditions = ""}
        
        if let specialFeaturesChecked = dict["Special Features"] {specialFeatures = specialFeaturesChecked} else {specialFeatures = ""}
        
        if let seasonChecked = dict["Season"] {season = seasonChecked} else {season = ""}
        
        if let bringChecked = dict["Bring"] {bring = bringChecked} else {bring = ""}
        
        // Load the clues
        self.loadClues(dict)
        self.addToSpotlight()
    }
    
    
    /*
        The following checks clue keys (Clue1, Clue2, Clue3) until there are none left
        It stores the values for all of these keys in the clues
    */
    private func loadClues(dict: Dictionary<String, String>) {
        self.clues = []
        
        // Remember the clue number
        var i = 1
        // This so that when it's all over we can get out
        var run = true
        
        while run {
            // Get the clue if it exists, else stop running
            if let clue = dict["Clue\(i)"] {
                // It exists! Store it
                self.clues.append(clue)
            }else{
                // We have seen the last one. We're done.
                run = false
            }
            // Increment
            i++
        }
    }
    
    func addToSpotlight() {
        let atributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeText as String)
        atributeSet.title = self.title
        atributeSet.contentDescription = self.description
        
        let searchItem = CSSearchableItem(uniqueIdentifier: "\(self.id)", domainIdentifier: "com.ValleyQuest.ValleyQuestApp", attributeSet: atributeSet)
        CSSearchableIndex.defaultSearchableIndex().indexSearchableItems([searchItem], completionHandler: { (error: NSError?) -> Void in
            if error != nil {
                print(error?.localizedDescription)
            }
        })
    }
    
    
    // ---------------------------
    // Static methods
    // ---------------------------
    
    /*
        Parses the given dictionary into quest objects, then returns an array of them.
    */
    static func getQuestsFromDictionary(dict: Dictionary<String, Dictionary<String, String>>) -> Array<Quest> {
        // Create a holder for the quests
        var quests: Array<Quest> = [];
        for (key, value) in dict {
            // Iterate through the dictionary and create and add quest objects
            quests.append(Quest(id: key, dict: value))
        }
        // Return the result
        return quests;
    }
    
    static func sortQuests(inout quests: Array<Quest>) {
        quickSort(&quests, start: 0, end: quests.count - 1)
    }
    
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
            if (compareValue.title > array[positon].title) {
                swap(&array, a: positon, b: under)
                under++
            }
            positon++
        }
        
        swap(&array, a: end, b: under)
        return under;
    }
    
    private static func swap(inout array: Array<Quest>, a: Int, b: Int) {
        let holder = array[a]
        array[a] = array[b]
        array[b] = holder
    }
}