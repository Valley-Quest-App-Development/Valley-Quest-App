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


class QuestDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    var titleCell: QuestDetailCell = QuestDetailCell()
    
    var object: Quest? = nil
    let regionRadius: CLLocationDistance = 1000
    private static let feedbackCellMessage = "Send feedback on this quest"
    var delegate: QuestController?
    
    var sections : [String] = []
    var rows : [[[String]]] = []
    
    var selectableRows: [NSIndexPath] = []
    
    
    override func viewWillAppear(animated: Bool) {
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.view.removeGestureRecognizer(self.revealViewController().panGestureRecognizer())
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
            selectableRows.append(NSIndexPath(forItem: rows[index].count - 1, inSection: index))
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
            
            if let book = quest.book {
                index = sections.count
                sections.append("Book")
                rows.append([])
                
                var data = ["Book", book]
                if let cluesLocation = quest.cluesLocation where !cluesLocation.containsString(".pdf") {
                    data = [quest.cluesLocation!, book]
                }
                rows[index].append(data)
                
                if let correction = quest.Correction {
                    rows[index].append(["Corrections", correction])
                    selectableRows.append(NSIndexPath(forItem: rows[index].count - 1, inSection: index))
                }
            }
            
            
            // Now add a view for feedback
            
            index = sections.count
            sections.append("Feedback")
            rows.append([])
            
            
            rows[index].append([QuestDetailViewController.feedbackCellMessage])
            selectableRows.append(NSIndexPath(forItem: rows[index].count - 1, inSection: index))
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let quest = object where indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("titleCell") as! QuestDetailCell
            
            cell.nameOfQuestLabel.text = quest.Name
            cell.setDifficulty(quest.Difficulty)
            if let duration = quest.duration as? Int {
                cell.setDuration("\(duration) mins")
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
                    let alert = UIAlertController(title: "Things to bring", message: quest.Bring, preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Done", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            break
            
            case "Corrections":
                let alert = UIAlertController(title: "Corrections", message: quest.Correction!, preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Done", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
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
        let saveQuest = UIPreviewAction(title: "Save", style: UIPreviewActionStyle.Default) { (action, viewController) -> Void in
            print("Need to save a quest!")
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
}