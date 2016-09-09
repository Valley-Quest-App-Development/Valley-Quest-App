//
//  AppDelegate.swift
//  Parse Modifier
//
//  Created by John Kotz on 8/22/16.
//  Copyright © 2016 John Kotz. All rights reserved.
//

import Cocoa
import Parse

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {



    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        
        Quest.registerSubclass()
        
        let ValleyQuestConfig = ParseClientConfiguration {
            $0.applicationId = "ZoalMIIVftZEKQoUcIWFkQqJWDsn2zYF8jJZiBlz"
            $0.clientKey = ""
            $0.server = "https://valleyquest.herokuapp.com/parse"
        }
        
        Parse.initializeWithConfiguration(ValleyQuestConfig)
        
        // For Bookup
//        MapBuildings.registerSubclass()
//        Parse.setApplicationId("rLEJCpuVNM98AqXD2s49TvVJAO1eCYULyhpE824l", clientKey: "uoJAfVJZwcRhzhUjAkuzb09ZidHD7Q8MwbJ8kxia")
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}

