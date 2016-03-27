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
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var difficulty: UILabel!
    @IBOutlet weak var descriptionLabel: UITextView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var descriptionHeight: NSLayoutConstraint!
    @IBOutlet weak var topView: UIView!
    var topHeight: CGFloat?
    
    var object: Quest? = nil
    let regionRadius: CLLocationDistance = 1000
    private static let feedbackCellMessage = "Send feedback on this quest"
    var delegate: QuestController?
    
    var sections : [String] = []
    var rows : [[[String]]] = []
    
    var selectableRows: [NSIndexPath] = []
    
    override func viewDidLoad() {
        
        if let quest = object {
            titleLabel.text = quest.Name
            difficulty.text = "Difficulty: " + quest.Difficulty
            
            
            let style = NSMutableParagraphStyle()
            style.lineSpacing = 5
            let atributes = [NSParagraphStyleAttributeName : style]
            descriptionLabel.attributedText = NSAttributedString(string: quest.Description, attributes: atributes)
            
            // We need outlets for locations and directions
            var index = sections.count
            sections.append("Location")
            rows.append([])
            
            rows[index].append([quest.Location, quest.directions])
            selectableRows.append(NSIndexPath(forItem: rows[index].count - 1, inSection: index))
            
            // We know that we need an outlet for the clues. That could be pdf or clues
            // The first section will be 
            
            index = sections.count
            sections.append("Details")
            rows.append([])
            
            rows[index].append(["Season", quest.Season])
            rows[index].append(["Type", quest.SpecialFeatures])
            rows[index].append(["Walking conditions", quest.WalkingConditions])
            rows[index].append(["Things to bring", quest.Bring])
            
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
            
            
            
            // Now add a view for feedback
            
            index = sections.count
            sections.append("Feedback")
            rows.append([])
            
            
            rows[index].append([QuestDetailViewController.feedbackCellMessage])
            selectableRows.append(NSIndexPath(forItem: rows[index].count - 1, inSection: index))
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell")
        
        cell?.textLabel?.text = rows[indexPath.section][indexPath.row][0]
        cell?.detailTextLabel?.text = rows[indexPath.section][indexPath.row].count > 1 ? rows[indexPath.section][indexPath.row][1] : ""
        if selectableRows.contains(indexPath) {
            cell?.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        }else{
            cell?.selectionStyle = UITableViewCellSelectionStyle.None
        }
        
        return cell!
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows[section].count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var animated = true
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
            if let url = NSURL(string: "http://appstore.com/valleyquest") {
                
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
            
            destination.setThings(quest.directions, coords: coords, name: quest.Name)
        }
        
        if let destination = segue.destinationViewController as? FeedbackViewController, let quest = object {
            destination.quest = quest
        }
    }
    
    func setQuestObject(object: Quest) {
        self.object = object
    }
    
    override func viewWillAppear(animated: Bool) {
        descriptionLabel.setContentOffset(CGPointZero, animated: animated)
    }
    
    override func viewDidLayoutSubviews() {
        descriptionLabel.setContentOffset(CGPointZero, animated: true)
        descriptionLabel.textContainer.lineFragmentPadding = 0
        
        let font = UIFont.systemFontOfSize(15)
        descriptionLabel.font = font
        
        let maxHeight:CGFloat = 180
        let height = HelperMethods.getHeightForText(descriptionLabel.text, font: font, width: self.descriptionLabel.frame.width, maxHeight: maxHeight)
        descriptionHeight.constant = height > maxHeight ? maxHeight : height
        
        
        let value = (self.navigationController?.navigationBar.frame.height)
        if self.topHeight == nil {
            self.topHeight = self.descriptionLabel.frame.origin.x + self.descriptionLabel.frame.height + (value == nil ? 0 : value!) + 15
        }
        self.topView.frame = CGRect(origin: self.topView.frame.origin, size: CGSize(width: self.topView.frame.width, height: self.topHeight!))
        
        descriptionLabel.scrollEnabled = height > maxHeight
    }
}