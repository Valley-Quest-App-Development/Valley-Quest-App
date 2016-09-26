//
//  AppDelegate.swift
//  Valley Quest
//
//  Created by John Kotz on 6/28/16.
//  Copyright © 2016 Valley Quest. All rights reserved.
//

import UIKit
import Parse
import SCLAlertView
import CoreSpotlight
import MobileCoreServices
import Fabric
import Crashlytics

let noCloseButton = SCLAlertView.SCLAppearance(
    showCloseButton: false
)

extension UIApplication {
    class func topViewController(base: UIViewController? = (UIApplication.sharedApplication().delegate as! AppDelegate).window?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(presented)
        }
        return base
    }
}

extension NSFileManager {
    class func documentsDir() -> String {
        var paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as [String]
        return paths[0]
    }
    
    class func cachesDir() -> String {
        var paths = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true) as [String]
        return paths[0]
    }
}


extension PFFile {
    func saveLocally() {
        saveLocallyWithBlock(nil)
    }
    
    func unsaveLocally() {
        unsaveLocallyWithBlock(nil)
    }
    
    private static func getDirectoryPath() -> NSURL? {
        return NSURL(fileURLWithPath: NSFileManager.documentsDir()).URLByAppendingPathComponent("pdfs")
    }
    
    func getLocalFilePath() -> NSURL? {
        return PFFile.getDirectoryPath()?.URLByAppendingPathComponent(self.name)
    }
    
    func getLocalFilePathString() -> String? {
        return self.getLocalFilePath()?.absoluteString?.stringByReplacingOccurrencesOfString("file://", withString: "")
    }
    
    func isSaved() -> Bool {
        print("is saved?")
        if let path = self.getLocalFilePath()?.absoluteString?.stringByReplacingOccurrencesOfString("file://", withString: "") {
            let result = NSFileManager.defaultManager().fileExistsAtPath(path)
            print(result ? "Yes" : "No")
            return result
        }
        
        print("No")
        return false
    }
    
    func unsaveLocallyWithBlock(block: PFBooleanResultBlock?) {
        if self.isSaved() {
            do {
                try NSFileManager.defaultManager().removeItemAtURL(self.getLocalFilePath()!)
                
                if let block = block {
                    block(true, nil)
                }
            } catch {
                if let block = block {
                    block(false, NSError(domain: "PFFile", code: 5001, userInfo: nil))
                }
            }
        }else{
            if let block = block {
                block(true, nil)
            }
        }
    }
    
    func saveLocallyWithBlock(block: PFBooleanResultBlock?) {
        dispatch_async(dispatch_queue_create("com.vitalcommunities.ValleyQuest", nil)) {
            self.getFilePathInBackgroundWithBlock { (url, error) in
                if let url = url {
                    
                    
                    let pdfData = NSData(contentsOfFile: url)
                    if let directory = PFFile.getDirectoryPath() {
                        
                        do {
                            try NSFileManager.defaultManager().createDirectoryAtURL(directory, withIntermediateDirectories: false, attributes: nil)
                        } catch {
                            // It already exists
                        }
                        
                        if let filePath = self.getLocalFilePath() {
                            
                            do {
                                try pdfData?.writeToURL(filePath, options: NSDataWritingOptions(rawValue: NSUTF8StringEncoding))
                            
                                dispatch_async(dispatch_get_main_queue(), {
                                    if let block = block {
                                        block(true, nil);
                                    }
                                })
                            } catch {
                                dispatch_async(dispatch_get_main_queue(), {
                                    if let block = block {
                                        block(false, NSError(domain: "PFFile", code: 5000, userInfo: nil));
                                    }
                                })
                            }
                        }else{
                            dispatch_async(dispatch_get_main_queue(), {
                                if let block = block {
                                    block(false, NSError(domain: "PFFile", code: 5000, userInfo: nil));
                                }
                            })
                        }
                    }
                }
            }
        }
    }
    
    func getFilePath(block: PFFilePathResultBlock?) {
        if (self.isSaved()) {
            print("Getting from local db")
            if let block = block {
                block(self.getLocalFilePathString(), nil)
            }
        }else{
            print("Getting from parse")
            self.getFilePathInBackgroundWithBlock(block)
        }
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var id: String?
    var mainViewController: QuestController?
    var locationController: LocationController?
    var sendFeedbackOnLoad = false
    
    let currentQuestShortcutItem = UIApplicationShortcutItem(type: "currentQuest", localizedTitle: "Active Quest", localizedSubtitle: nil, icon: UIApplicationShortcutIcon(type: .Play), userInfo: nil)
    let feedbackShortcutItem = UIApplicationShortcutItem(type: "feedback", localizedTitle: "Send Feedback", localizedSubtitle: nil, icon: UIApplicationShortcutIcon(type: .Compose), userInfo: nil)
    
    func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
        print("url: \(url.absoluteString) options: \(options)")
        if let id = url.host where id != "" {
            loadQuest(id);
        }
        return true
    }
    
    func application(application: UIApplication, performActionForShortcutItem shortcutItem: UIApplicationShortcutItem, completionHandler: (Bool) -> Void) {
        if shortcutItem == currentQuestShortcutItem {
            if let id = State.getQuestID() {
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: "goToPDF")
                loadQuest(id)
                completionHandler(true)
            }
        }else if shortcutItem.type == "feedback" {
            if let mainViewController = mainViewController {
                mainViewController.sendFeedback()
            }else{
                sendFeedbackOnLoad = true
            }
            completionHandler(true)
        }else{
            completionHandler(false)
        }
    }
    
    func evaluateShortCuts() {
        var shortcuts: [UIApplicationShortcutItem] = []
        if State.getQuestID() != nil  {
            shortcuts.append(currentQuestShortcutItem)
        }
        shortcuts.append(feedbackShortcutItem)
        UIApplication.sharedApplication().shortcutItems = shortcuts
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        Fabric.with([Crashlytics.self])
        
        evaluateShortCuts()

        Quest.registerSubclass()
        Feedback.registerSubclass()
        QuestGPSSet.registerSubclass()
        
        // Initialize Parse.
        let parseConfig = ParseClientConfiguration {
            $0.applicationId = "ZoalMIIVftZEKQoUcIWFkQqJWDsn2zYF8jJZiBlz"
            $0.clientKey = ""
            $0.server = "https://valleyquest.herokuapp.com/parse"
            $0.localDatastoreEnabled = true
        }
        //        Parse.setApplicationId("ZoalMIIVftZEKQoUcIWFkQqJWDsn2zYF8jJZiBlz", clientKey: "Sd3CVO3sXH8muH70ut5fOINuvee4zk8OaAxyoxTH")
        Parse.enableLocalDatastore()
        Parse.initializeWithConfiguration(parseConfig)
        
        var configureError:NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(configureError)")
        
        // Override point for customization after application launch.
        return true
    }
    
    func registerMainViewController(viewController: QuestController) {
        self.mainViewController = viewController
        if let id = id {
            viewController.loadQuestView(id)
        }
        
        if sendFeedbackOnLoad {
            viewController.sendFeedback()
        }
        
        sendFeedbackOnLoad = false
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

    func application(application: UIApplication, supportedInterfaceOrientationsForWindow window: UIWindow?) -> UIInterfaceOrientationMask {
        if UIApplication.topViewController() is PDFViewController {
            return UIInterfaceOrientationMask.AllButUpsideDown
        }else{
            return UIInterfaceOrientationMask.Portrait
        }
    }
    
    
    func application(application: UIApplication, continueUserActivity userActivity: NSUserActivity, restorationHandler: ([AnyObject]?) -> Void) -> Bool {
        if userActivity.activityType == CSSearchableItemActionType {
            if let id = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String {
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: "goToPDF")
                loadQuest(id);
            }
        }
        
        return true
    }
    
    
    func loadQuest(id: String) {
        self.id = id
        if let navController = self.window!.rootViewController as? UINavigationController {
            navController.popToRootViewControllerAnimated(true)
            
            if let mainVC = navController.topViewController as? QuestController {
                mainVC.loadQuestView(id)
                self.id = nil
                return
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

