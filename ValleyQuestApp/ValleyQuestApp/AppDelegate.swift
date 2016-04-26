//
//  AppDelegate.swift
//  ValleyQuestApp
//
//  Created by John Kotz on 9/29/15.
//  Copyright © 2015 Valley Quest App Dev. All rights reserved.
//

import UIKit
import Foundation
import CoreSpotlight
import MobileCoreServices
import Parse

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var id: String?
    var mainViewController: QuestController?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        let currentQuestShortcutItem = UIApplicationShortcutItem(type: "currentQuest", localizedTitle: "Go to Current Quest")
        let savedQuestShortcutItem = UIApplicationShortcutItem(type: "savedQuest", localizedTitle: "Saved Quests")
        let shortcuts = [currentQuestShortcutItem, savedQuestShortcutItem]
        
        Quest.registerSubclass()
        Feedback.registerSubclass()
        UIApplication.sharedApplication().shortcutItems = shortcuts
        
        Parse.setApplicationId("ZoalMIIVftZEKQoUcIWFkQqJWDsn2zYF8jJZiBlz", clientKey: "Sd3CVO3sXH8muH70ut5fOINuvee4zk8OaAxyoxTH")
        
        
        return true
    }
    
    func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
        print("url: \(url.absoluteString) options: \(options)")
        return true
    }
    
    func registerMainViewController(viewController: QuestController) {
        self.mainViewController = viewController
        if let id = id {
            viewController.loadQuestView(id)
        }
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(application: UIApplication, continueUserActivity userActivity: NSUserActivity, restorationHandler: ([AnyObject]?) -> Void) -> Bool {
        if userActivity.activityType == CSSearchableItemActionType {
            if let id = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String {
                self.id = id
                let mainController = self.window!.rootViewController as! SWRevealViewController
                if let navController = mainController.rightViewController as? UINavigationController {
                    navController.popToRootViewControllerAnimated(true)
                    
                    if let mainVC = navController.topViewController as? QuestController {
                        mainVC.loadQuestView(id)
                        self.id = nil
                        return true;
                    }
                }else{
                    // We failed to get it!
                    // Try this
                    if let mainViewController = self.mainViewController {
                        mainViewController.loadQuestView(id)
                        self.id = nil
                    }
                }
            }
        }
        
        
        
        return true
    }

}

