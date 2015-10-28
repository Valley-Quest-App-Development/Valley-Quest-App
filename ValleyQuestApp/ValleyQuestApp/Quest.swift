//
//  Quests.swift
//  ValleyQuestApp
//
//  Created by John Kotz on 10/27/15.
//  Copyright © 2015 Valley Quest App Dev. All rights reserved.
//

import Foundation

class Quest {
    // ---------------------------
    // Data and storage variables
    // ---------------------------
    
    // Some of the data
    private var id: String
    private var clues: Array<String>
    
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
    
    static func getQuestsFromDictionary(dict: Dictionary<String, Dictionary<String, String>>) -> Array<Quest> {
        var quests: Array<Quest> = [];
        for (key, value) in dict {
            quests.append(Quest(id: key, dict: value))
        }
        return quests;
    }
}