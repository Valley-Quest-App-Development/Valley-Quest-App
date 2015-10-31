//
//  Quests.swift
//  ValleyQuestApp
//
//  Created by John Kotz on 10/27/15.
//  Copyright © 2015 Valley Quest App Dev. All rights reserved.
//

import Foundation

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
    
    // Some of the data
    var id: String {
        // You can get it but you can't set it
        get {
            return self.id
        }
        set {}
    }
    
    var title: String{
        // you can get it but you can't set it 
        get{
            return self.title
        }
        set{}
    }
    
    var duration: String{
        // you can get it but you can't set it 
        get{
            return self.duration
        }
        set{}
    }
    
    var difficulty: String{
        //you can get it but you can't set it
        get{
            return self.difficulty
        }
        
        set{}
    }
    var clues: Array<String> {
        // You can get it but you can't set it
        // It also only returns a copy, so you can't manipulate the values
        // Just don't use this.
        get {
            return self.clues.copy()
        }
        set {}
    }
    
    // The rest of the data
    // Wendell will fill this in
    
    
    
    

    
    
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
        
        // Load the clues
        self.loadClues(dict)
        
        // Get the rest of the data
        // Serena will fill this in
        
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
}