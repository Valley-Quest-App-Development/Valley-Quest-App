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



    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
//        Quest.registerSubclass()
        
//        let ValleyQuestConfig = ParseClientConfiguration {
//            $0.applicationId = "ZoalMIIVftZEKQoUcIWFkQqJWDsn2zYF8jJZiBlz"
//            $0.clientKey = ""
//            $0.server = "https://valleyquest.herokuapp.com/parse"
//        }
        
        let BookUpConfig = ParseClientConfiguration {
            $0.applicationId = "xFhKltIX51WKUXEWdAqzN1rahdMyIHewhsaFoOtj"
            $0.clientKey = ""
            $0.server = "https://bookup-parse-server.herokuapp.com/parse"
        }
        
        Parse.initialize(with: BookUpConfig)
        
        // For Bookup
//        MapBuildings.registerSubclass()
//        Parse.setApplicationId("rLEJCpuVNM98AqXD2s49TvVJAO1eCYULyhpE824l", clientKey: "uoJAfVJZwcRhzhUjAkuzb09ZidHD7Q8MwbJ8kxia")
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

