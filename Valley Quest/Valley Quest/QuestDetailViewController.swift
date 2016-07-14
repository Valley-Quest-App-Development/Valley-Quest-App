//
//  QuestDetailViewController.swift
//  ValleyQuestApp
//
//  Created by Seb Lim on 10/28/15.
//  Copyright © 2015 John Kotz. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import Parse
import MessageUI
import SCLAlertView
import Crashlytics


class QuestDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    var titleCell: QuestDetailCell = QuestDetailCell()
    
    var object: Quest? = nil
    let regionRadius: CLLocationDistance = 1000
    private static let feedbackCellMessage = "Send feedback on this quest"
    var delegate: QuestController?
    
    var sections : [String] = []
    var rows : [[[String]]] = []
    
    var saved = false;
    var showFeedback = false
    
    var selectableRows: [NSIndexPath] = []
    
    
    override func viewDidAppear(animated: Bool) {
//        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        
        if showFeedback {
            self.performSegueWithIdentifier("showFeedbackView", sender: nil)
            showFeedback = false
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
//        self.view.removeGestureRecognizer(self.revealViewController().panGestureRecognizer())
    }
    
    override func viewDidLoad() {
        
        if let quest = object {
            
            // We need outlets for locations and directions
            sections.append("")
            rows.append([[]])
            
            var index = sections.count
            sections.append("Location")
            rows.append([])
            
            rows[index].append([quest.Location, quest.Directions])
            if quest.Directions != "" {
                selectableRows.append(NSIndexPath(forItem: rows[index].count - 1, inSection: index))
            }
//
//            
//            index = sections.count
//            sections.append("Overview")
//            rows.append([])
//            
//            rows[index].append(["", ])
//            
            // We know that we need an outlet for the clues. That could be pdf or clues
            // The first section will be 
            
            index = sections.count
            sections.append("Details")
            rows.append([])
            
            rows[index].append(["Season", quest.Season])
            rows[index].append(["Type", quest.SpecialFeatures])
            rows[index].append(["Walking conditions", quest.WalkingConditions])
            if let bring = quest.Bring {
                rows[index].append(["Things to bring", bring])
            }
            
            Answers.logCustomEventWithName("Quest View", customAttributes: ["name" : quest.Name])
            
            if quest.hasClues() || quest.hasPDF() {
                
                
                let textSize = UIFont.systemFontOfSize(16).sizeOfString(rows[index][rows[index].count - 1][1], constrainedToWidth: Double(self.view.frame.width)).width
                
                let mainTitleWidth = UIFont.systemFontOfSize(16).sizeOfString(rows[index][rows[index].count - 1][0], constrainedToWidth: Double(self.view.frame.width)).width
                
                // This determines if the string is too long to all be shown. If it is, we make is selectable so we can expand it for people
                if textSize > self.view.frame.width - mainTitleWidth - 30 {
                    selectableRows.append(NSIndexPath(forItem: rows[index].count - 1, inSection: index))
                }
                
                // If there is a pdf, we can show it
                if quest.hasPDF() {
                    rows[index].append(["PDF"])
                    selectableRows.append(NSIndexPath(forItem: rows[index].count - 1, inSection: index))
                }
                
                if quest.hasClues() {
                    rows[index].append(["Clues"])
                    selectableRows.append(NSIndexPath(forItem: rows[index].count - 1, inSection: index))
                }
            }
            
            
            
            if let correction = quest.Correction {
                rows[index].append(["Corrections", correction])
                selectableRows.append(NSIndexPath(forItem: rows[index].count - 1, inSection: index))
            }
            
//            if let book = quest.book {
//                index = sections.count
//                sections.append("Book")
//                rows.append([])
//                
//                var data = ["Book", book]
//                if let cluesLocation = quest.cluesLocation where !cluesLocation.containsString(".pdf") {
//                    data = [quest.cluesLocation!, book]
//                }
//                rows[index].append(data)
//            }
            
            
            // Now add a view for feedback
            
            index = sections.count
            sections.append("Feedback")
            rows.append([])
            
            
            rows[index].append([QuestDetailViewController.feedbackCellMessage])
            selectableRows.append(NSIndexPath(forItem: rows[index].count - 1, inSection: index))
        }
    }
    
    func saveQuestCheck() {
        if let inProgress = State.questInProgress where object!.objectId == inProgress.objectId && saved {
            let alert = SCLAlertView(appearance: noCloseButton)
            alert.addButton("Unsave", action: { 
                self.saveQuest()
            })
            alert.addButton("Nevermind", action: {})
            
            alert.showInfo("Unsave?", subTitle: "This quest was auto-saved because it is your active quest. Are you sure you want to unsave it?")
        }else{
            self.saveQuest()
        }
    }
    
    func saveQuest() {
        if let quest = object {
            if saved {
                // Then unsave it
                quest.unpinInBackgroundWithBlock({ (success, error) in
                    if success {
                        self.saved = false
                        self.titleCell.endLoadingSave(false)
                        Answers.logCustomEventWithName("Unsaved quest", customAttributes: ["name" : quest.Name])
                        if let delegate = self.delegate {
                            if let index = delegate.savedQuests.indexOf(quest) {
                                delegate.savedQuests.removeAtIndex(index)
                            }
                            delegate.tableView.reloadData()
                        }
                    }else{
                        print(error?.description)
                        self.titleCell.endLoadingSave(true)
                        SCLAlertView().showError("Failed to unsave!", subTitle: "Contact Vital Communities for support")
                    }
                })
            }else{
                // Save it
                quest.pinInBackgroundWithBlock({ (success, error) in
                    if success {
                        self.saved = true
                        self.titleCell.endLoadingSave(true)
                        Answers.logCustomEventWithName("Saved quest", customAttributes: ["name" : quest.Name])
                        if let delegate = self.delegate {
                            if delegate.savedQuests.indexOf(quest) == nil {
                                delegate.savedQuests.append(quest)
                                Quest.sortQuests(&delegate.savedQuests)
                            }
                            delegate.tableView.reloadData()
                        }
                        
                        if NSUserDefaults.standardUserDefaults().objectForKey("saveDone") == nil || !NSUserDefaults.standardUserDefaults().boolForKey("saveDone") {
                            SCLAlertView().showSuccess("Saved!", subTitle: "Your saved quests will be shown at the top of the quest list")
                        }
                        
                        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "saveDone")
                    }else{
                        print(error?.description)
                        self.titleCell.endLoadingSave(true)
                        SCLAlertView().showError("Failed to save!", subTitle: "Contact Vital Communities for support")
                    }
                })
            }
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let quest = object where indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("titleCell") as! QuestDetailCell
            cell.delegate = self;
            
            cell.nameOfQuestLabel.text = quest.Name
            if !quest.isClosed() {
                cell.setDifficulty(quest.Difficulty)
                if let duration = quest.duration as? Int {
                    cell.setDuration("\(duration) mins")
                }
            }else{
                cell.makeClosed()
            }
            
            var finalString = quest.Description
            
            if let overview = quest.overview {
                if (finalString != "") {
                    finalString += "\n\n"
                }
                finalString += "Overview: " + overview
            }
            
            cell.setDescription(finalString)
            cell.descriptionTextView.dataDetectorTypes = .All
            cell.userInteractionEnabled = true;
            
            titleCell = cell
            
            let query = PFQuery(className: "Quests")
            query.fromLocalDatastore()
            query.findObjectsInBackgroundWithBlock({ (objects, error) in
                if let objects = objects {
                    for object in objects {
                        if object.objectId == quest.objectId {
                            // It was previously there
                            self.saved = true;
                            dispatch_async(dispatch_get_main_queue(), {
                                self.titleCell.endLoadingSave(true)
                            })
                            return
                        }
                    }
                }
                dispatch_async(dispatch_get_main_queue(), {
                    self.titleCell.endLoadingSave(false)
                })
            })
            cell.selectionStyle = .None
            cell.initialize()
            
            return cell
        }
        
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell")
        
        cell?.textLabel?.text = rows[indexPath.section][indexPath.row][0]
        cell?.detailTextLabel?.text = rows[indexPath.section ][indexPath.row].count > 1 ? rows[indexPath.section][indexPath.row][1] : ""
        if selectableRowsContains(indexPath) {
            cell?.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        }else{
            cell?.accessoryType = .None
            cell?.selectionStyle = UITableViewCellSelectionStyle.None
        }
        
        return cell!
    }
    
    private func selectableRowsContains(indexPath: NSIndexPath) -> Bool {
        for path in selectableRows {
            if (indexPath.row == path.row && indexPath.section == path.section) {
                return true
            }
        }
        return false
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return titleCell.getHeight()
        }
        
        return 50
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows[section].count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var animated = false
        let quest = object!
        
        if indexPath.section == 0 {
            self.tableView.deselectRowAtIndexPath(indexPath, animated: false)
            return;
        }
        
        switch rows[indexPath.section][indexPath.row][0]{
            case "PDF":
                animated = quest.hasPDF()
                self.performSegueWithIdentifier("showPDF", sender: quest.pdf)
            break
            
            case "Clues":
                animated = quest.hasClues()
                self.performSegueWithIdentifier("showClues", sender: nil)
            break
            
            case quest.Location:
                animated = true
                self.performSegueWithIdentifier("showDirections", sender: nil)
            break
            
            case "Things to bring":
                if (self.selectableRows.contains(indexPath)) {
                    animated = true
                    SCLAlertView().showInfo("Things to bring", subTitle: String(quest.Bring))
                }
            break
            
            case "Corrections":
                SCLAlertView().showInfo("Corrections", subTitle: String(quest.Correction!))
            break
            
            case QuestDetailViewController.feedbackCellMessage:
                self.performSegueWithIdentifier("showFeedbackView", sender: nil)
            break
            
            default:
                animated = false
            break
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: animated)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func previewActionItems() -> [UIPreviewActionItem] {
        let saveQuest = UIPreviewAction(title: self.saved ? "Unsave" : "Save", style: UIPreviewActionStyle.Default) { (action, viewController) -> Void in
            self.saveQuest()
        }
        
        let share = UIPreviewAction(title: "Share", style: UIPreviewActionStyle.Default) { (action, viewController) -> Void in
            self.shareQuest(nil, viewController: self.delegate!)
        }
        
        return [saveQuest, share]
    }
    
    @IBAction func share(sender: UIBarButtonItem) {
        self.shareQuest(sender, viewController: self)
    }
    
    func shareQuest(barButton: UIBarButtonItem?, viewController: UIViewController) {
        if let quest = object {
            let textToShare = "Check out the quest " + quest.Name + " in the Valley Quest app\n"
            if let url = NSURL(string: "VitalCommunities://\(quest.objectId!)") {
                
                let activity: UIActivityViewController = UIActivityViewController(activityItems: [textToShare, url, quest], applicationActivities: nil)
                
                
                
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.Pad) {
                    if let sender = barButton {
                        activity.modalPresentationStyle = UIModalPresentationStyle.Popover
                        activity.popoverPresentationController!.barButtonItem = sender
                    }
                }
                
                
                viewController.presentViewController(activity, animated: true, completion: nil)
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let viewController = segue.destinationViewController as? CluesViewController {
            viewController.set(object!)
        }
        
        if let destination = segue.destinationViewController as? PDFViewController {
            destination.setObject(sender as! PFFile)
            destination.quest = object
        }
        
        if let destination = segue.destinationViewController as? DirectionsViewController, let quest = object {
            var coords: CLLocationCoordinate2D?
            if let gps = quest.GPS {
                coords = CLLocationCoordinate2DMake(gps.latitude, gps.longitude)
            }
            
            destination.setThings(quest.Directions, coords: coords, name: quest.Name)
        }
        
        if let destination = segue.destinationViewController as? FeedbackViewController, let quest = object {
            destination.quest = quest
        }
    }
    
    func setQuestObject(object: Quest) {
        self.object = object
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
}