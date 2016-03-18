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

class QuestDetailViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var difficulty: UILabel!
    @IBOutlet weak var descriptionLabel: UITextView!
    
    @IBOutlet weak var descriptionHeight: NSLayoutConstraint!
    
    var object: Quest? = nil
    let regionRadius: CLLocationDistance = 1000
    
    override func viewDidLoad() {
        
        self.navigationItem
        
        if let quest = object {
            titleLabel.text = quest.Name
            difficulty.text = "Difficulty: " + quest.Difficulty
            
            descriptionLabel.text = quest.Description
            print(quest.Description)
            let font = UIFont.systemFontOfSize(15)
            descriptionLabel.font = font
            
            let maxHeight:CGFloat = 200
            let height = HelperMethods.getHeightForText(descriptionLabel.text, font: font, width: descriptionLabel.frame.width, maxHeight: maxHeight) + font.lineHeight
            descriptionHeight.constant = height > maxHeight ? maxHeight : height
            
            if height > maxHeight {
                descriptionLabel.scrollEnabled = true
            }
        }
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
    
    @IBAction func startQuest(sender: UIButton) {
        if let quest = object, let clues = quest.Clues {
            self.performSegueWithIdentifier("showClues", sender: clues)
        }else if let quest = object, let pdf = quest.pdf {
            self.performSegueWithIdentifier("showPDF", sender: pdf)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let viewController = segue.destinationViewController as? CluesViewController {
            viewController.set(object!)
        }
        
        if let destination = segue.destinationViewController as? PDFViewController {
            destination.setObject(sender as! PFFile)
            if let quest = object {
                if quest.hasGPS() {
                    destination.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Go there", style: UIBarButtonItemStyle.Plain, target: self, action: "openLocation")
                }
            }
        }
    }
    
    @IBAction func showClues(sender: AnyObject) {
        self.performSegueWithIdentifier("showClues", sender: nil)
    }
    
    func setQuestObject(object: Quest) {
        self.object = object
    }
    
    override func viewDidLayoutSubviews() {
        descriptionLabel.setContentOffset(CGPointZero, animated: false)
    }
}