//
//  PDFViewer.swift
//  ValleyQuestApp
//
//  Created by John Kotz on 2/2/16.
//  Copyright © 2016 John Kotz. All rights reserved.
//

import Foundation
import UIKit
import Parse
import SCLAlertView
import Crashlytics

let FINISH_QUEST_KEY = "finished_quest"
let START_QUEST_KEY = "start_quest"

class PDFViewController: UIViewController, UIWebViewDelegate {
    @IBOutlet weak var pdfView: UIWebView!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var hintButton: UIBarButtonItem!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var file: PFFile?
    var quest: Quest!
    var delegate: QuestDetailViewController?
    var startGPSSet = QuestGPSSet()
    var endGPSSet = QuestGPSSet()
    var boxGPSSet = QuestGPSSet()
    
    override func viewDidLoad() {
        if file != nil {
            updateView()
            self.pdfView.scalesPageToFit = true
        }
        
        startButton.enabled = false
        State.loadQuestInProgress { (quest, error) in
            if let quest = quest where (error == nil && quest.objectId == self.quest.objectId) {
                self.startButton.setTitle("Finish", forState: .Normal)
                self.startButton.setBackgroundImage(UIImage(named: "BubbleSecond"), forState: .Normal)
                self.cancelButton.enabled = true
            }
            self.startButton.enabled = true
        }
        
        activityIndicator.startAnimating()
        
        if QuestGPSSet.GPSIsEnabled() {
            hintButton.title = "Mark box"
            hintButton.enabled = true
        }
    }
    
    func updateView() {
        if let activityIndicator = activityIndicator {
            activityIndicator.startAnimating()
        }
        file?.getFilePathInBackgroundWithBlock({ (path, error) -> Void in
            if let checkedPath = path {
                if self.pdfView != nil {
                    self.pdfView.loadRequest(NSURLRequest(URL: NSURL.fileURLWithPath(checkedPath)))
                    self.pdfView.delegate = self
                    self.pdfView.hidden = false
                }
            }else{
                print("Error!! \(error)")
            }
        })
    }
    
    @IBAction func cancelQuest(sender: AnyObject) {
        State.questInProgress = nil
        Answers.logCustomEventWithName("Canceled Quest", customAttributes: ["name":quest.Name])
        self.makeFinished()
    }
    
    @IBAction func hintButtonPressed(sender: AnyObject) {
        if QuestGPSSet.GPSIsEnabled() {
            if let delegate = UIApplication.sharedApplication().delegate as? AppDelegate {
                delegate.locationController?.getOneLocation({ (loc) in
                    self.boxGPSSet.quest = self.quest
                    self.boxGPSSet.addBox(loc)
                })
            }
        }
    }
    
    func makeQuestInProgress() {
        self.startButton.enabled = true
        self.cancelButton.enabled = true
        self.startButton.setTitle("Finish", forState: .Normal)
        self.startButton.setBackgroundImage(UIImage(named: "BubbleSecond"), forState: .Normal)
        if QuestGPSSet.GPSIsEnabled() {
            if let delegate = UIApplication.sharedApplication().delegate as? AppDelegate {
                delegate.locationController?.getOneLocation({ (loc) in
                    self.startGPSSet.quest = self.quest
                    self.startGPSSet.addStart(loc)
                })
            }
        }
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.send(GAIDictionaryBuilder.createEventWithCategory(
                USER_ACTION_KEY,
                action: START_QUEST_KEY,
                label: quest.objectId,
                value: nil
            ).build() as [NSObject : AnyObject])
        
        if let delegate = UIApplication.sharedApplication().delegate as? AppDelegate {
            delegate.evaluateShortCuts()
        }
    }
    
    func makeFinished() {
        self.startButton.enabled = true
        self.cancelButton.enabled = false
        self.startButton.setTitle("Start", forState: .Normal)
        self.startButton.setBackgroundImage(UIImage(named: "Bubble"), forState: .Normal)
        if QuestGPSSet.GPSIsEnabled() {
            if let delegate = UIApplication.sharedApplication().delegate as? AppDelegate {
                delegate.locationController?.getOneLocation({ (loc) in
                    self.endGPSSet.quest = self.quest
                    self.endGPSSet.addEnd(loc)
                })
            }
        }
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.send(GAIDictionaryBuilder.createEventWithCategory(
                USER_ACTION_KEY,
                action: FINISH_QUEST_KEY,
                label: quest.objectId,
                value: nil
            ).build() as [NSObject : AnyObject])
        
        if let delegate = UIApplication.sharedApplication().delegate as? AppDelegate {
            delegate.evaluateShortCuts()
        }
    }
    
    @IBAction func startQuest(sender: UIButton) {
        if (self.pdfView.hidden) {
            SCLAlertView().showNotice("Still loading", subTitle: "You can't start the quest until you have the clues")
            return
        }
        
        
        if (State.questInProgress == nil || State.questInProgress?.objectId != quest.objectId) {
            // Starting a quest
            
            if let prevQuest = State.questInProgress {
                // Show alert for a previous quest
                
                let alert = SCLAlertView(appearance: noCloseButton)
                alert.addButton("Finish it", action: {
                    State.finishQuest()
                    State.questInProgress = self.quest
                    self.makeQuestInProgress()
                })
                alert.addButton("Cancel it", action: {
                    Answers.logCustomEventWithName("Canceled Quest", customAttributes: ["name":prevQuest.Name])
                    State.questInProgress = self.quest
                    self.makeQuestInProgress()
                })
                alert.addButton("Dismiss", action: {})
                
                alert.showWarning("Already questing", subTitle: "You already have another quest active (\(prevQuest.Name)). Do you want to end that one?")
            
            
            }else{
                // Start new quest
                
                State.questInProgress = quest
                self.makeQuestInProgress()
            }
        }else{
            // Moving to finish quest!
            
            
            State.finishQuest()
            self.makeFinished()
            
            // Show a message
            if let numComplete = NSUserDefaults.standardUserDefaults().objectForKey("questsCompleted") as? Int {
                let alert = SCLAlertView()
                alert.addButton("Send feedback", action: {
                    if let delegate = self.delegate {
                        delegate.showFeedback = true
                        self.navigationController?.popViewControllerAnimated(true)
                    }else{
                        self.performSegueWithIdentifier("pdfToFeedback", sender: nil)
                    }
                })
                alert.addButton("Rate the app", action: {
                    UIApplication.sharedApplication().openURL(NSURL(string : "itms-apps://itunes.apple.com/app/id1083576851")!)
                })
                alert.showSuccess("Complete", subTitle: "You have now completed \(numComplete + 1) quests! Nice work!")
                NSUserDefaults.standardUserDefaults().setInteger(numComplete + 1, forKey: "questsCompleted")
            }else{
                SCLAlertView().showSuccess("Complete", subTitle: "You have completed your first quest! Nice work!")
                NSUserDefaults.standardUserDefaults().setInteger(1, forKey: "questsCompleted")
            }
        }
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        if (UIDevice.currentDevice().userInterfaceIdiom == .Phone) {
            webView.scrollView.setContentOffset(CGPointMake(0, -self.navigationController!.navigationBar.frame.height - 15), animated: false)
            activityIndicator.stopAnimating()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destination = segue.destinationViewController as? FeedbackViewController {
            destination.quest = quest
        }
    }
    
    func setObject(file: PFFile) {
        self.file = file
        updateView()
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.AllButUpsideDown
    }
    
}