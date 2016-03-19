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
    
    var object: Quest? = nil
    let regionRadius: CLLocationDistance = 1000
    
    var sections : [String] = []
    var rows : [[String]] = []
    
    var selectableRows: [NSIndexPath] = []
    
    override func viewDidLoad() {
        
        if let quest = object {
            titleLabel.text = quest.Name
            difficulty.text = "Difficulty: " + quest.Difficulty
            
            descriptionLabel.text = quest.Description
            
            // We need outlets for locations and directions
            let index = sections.count
            sections.append("Location")
            rows.append([])
                
            rows[index].append(quest.Location)
            if quest.hasGPS() {
                selectableRows.append(NSIndexPath(forItem: rows[index].count - 1, inSection: index))
            }
            
            // We know that we need an outlet for the clues. That could be pdf or clues
            // The first section will be 
            if quest.hasClues() || quest.hasPDF() {
                let index = sections.count
                sections.append("Details")
                rows.append([])
                
                if quest.hasPDF() {
                    rows[index].append("PDF")
                    selectableRows.append(NSIndexPath(forItem: rows[index].count - 1, inSection: index))
                }
                
                if quest.hasClues() {
                    rows[index].append("Clues")
                    selectableRows.append(NSIndexPath(forItem: rows[index].count - 1, inSection: index))
                }
            }
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell")
        
        cell?.textLabel?.text = rows[indexPath.section][indexPath.row]
        if selectableRows.contains(indexPath) {
            cell?.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
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
        
        switch rows[indexPath.section][indexPath.row]{
            case "PDF":
                animated = quest.hasPDF()
                self.performSegueWithIdentifier("showPDF", sender: quest.pdf)
            break
            
            case "Clues":
                animated = quest.hasClues()
                self.performSegueWithIdentifier("showClues", sender: nil)
            break
            
            case quest.Location:
                animated = quest.hasGPS()
                openLocation()
            break
            
            default:
                animated = false
                print("Unknown cell clicked")
            break
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: animated)
    }
    
    func openLocation() {
        let quest = object!
        let lat: CLLocationDegrees = quest.GPS!.latitude
        let long: CLLocationDegrees = quest.GPS!.longitude
        
        let coords = CLLocationCoordinate2DMake(lat, long)
        let dist: CLLocationDistance = 10000
        let span = MKCoordinateRegionMakeWithDistance(coords, dist, dist)
        
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(MKCoordinate: span.center),
            MKLaunchOptionsMapSpanKey: NSValue(MKCoordinateSpan: span.span)
        ]
        
        let placemark = MKPlacemark(coordinate: coords, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "\(quest.Name)"
        mapItem.openInMapsWithLaunchOptions(options)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func previewActionItems() -> [UIPreviewActionItem] {
        let saveQuest = UIPreviewAction(title: "Save", style: UIPreviewActionStyle.Default) { (action, viewController) -> Void in
            print("Need to save a quest!")
        }
        
        let share = UIPreviewAction(title: "Share", style: UIPreviewActionStyle.Default) { (action, viewController) -> Void in
            print("Need to share a quest!")
        }
        
        return [saveQuest, share]
    }
    
    @IBAction func share(sender: UIBarButtonItem) {
        if let quest = object {
            let textToShare = "Check out the quest " + quest.Name + " in the Valley Quest app\n"
            if let url = NSURL(string: "http://appstore.com/valleyquest") {
                
                let activity: UIActivityViewController = UIActivityViewController(activityItems: [textToShare, url, quest], applicationActivities: nil)
                activity.excludedActivityTypes = [UIActivityTypeAddToReadingList]
                
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.Pad) {
                    activity.modalPresentationStyle = UIModalPresentationStyle.Popover
                    activity.popoverPresentationController!.barButtonItem = sender
                }
                
                
                self.presentViewController(activity, animated: true, completion: nil)
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
    }
    
    func setQuestObject(object: Quest) {
        self.object = object
    }
    
    override func viewDidLayoutSubviews() {
        descriptionLabel.setContentOffset(CGPointZero, animated: false)
        descriptionLabel.textContainer.lineFragmentPadding = 0
        
        let font = UIFont.systemFontOfSize(15)
        descriptionLabel.font = font
        
        let maxHeight:CGFloat = 160
        let height = HelperMethods.getHeightForText(descriptionLabel.text, font: font, width: self.descriptionLabel.frame.width, maxHeight: maxHeight)
        descriptionHeight.constant = height > maxHeight ? maxHeight : height
        
        if height > maxHeight {
            descriptionLabel.scrollEnabled = true
        }
    }
}