//
//  FeedbackBoxViewController.swift
//  Valley Quest App
//
//  Created by John Kotz on 3/22/16.
//  Copyright © 2016 vitalCommunities. All rights reserved.
//

import Foundation
import SCLAlertView

class FeedbackBoxViewController: UITableViewController {
    var moreTextView: UITextView = UITextView()
    var feedBack: Feedback?
    var percentCell: PercentCell?
    var qualityCell: QualityCell?
    
    var selectedItems: [String] = []
    
    override func viewDidLoad() {
        self.title = "Feedback - Box"
        if let prevSelected = feedBack?.boxMissingItems {
            selectedItems = prevSelected
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            // It is percentage of book
            if percentCell != nil {
                return percentCell!
            }
            
            let cell = tableView.dequeueReusableCellWithIdentifier("percentCell") as! PercentCell
            cell.selectionStyle = .None
            percentCell = cell
            cell.percent = 0.5
            
            if let used = feedBack?.percentOfBookUsed {
                cell.percent = Double(used)
            }
            
            return cell
            
        case 1:
            // Main box
            switch indexPath.row {
            case 0:
                // Quality
                if let qualityCell = qualityCell {
                    return qualityCell
                }
                
                let cell = tableView.dequeueReusableCellWithIdentifier("qualityCell") as! QualityCell
                qualityCell = cell
                cell.selectionStyle = .None
                
                if let qualString = feedBack?.boxQuality {
                    if let index = Feedback.boxQualityOptions.indexOf(qualString) {
                        qualityCell?.qualitySegmentedControl.selectedSegmentIndex = index
                    }
                }
                
                return cell
            
            case 1:
                // Missing items
                let cell = tableView.dequeueReusableCellWithIdentifier("cell")!
                cell.accessoryType = .DisclosureIndicator
                cell.selectionStyle = .Gray
                cell.textLabel?.text = "Missing Items"
                return cell
            default:
                break
            }
            break
            
        case 2:
            // More
            var cell = tableView.dequeueReusableCellWithIdentifier("cell") as? FeedbackTextViewCell
            
            if cell == nil {
                let nib: NSArray = NSBundle.mainBundle().loadNibNamed("FeedbackTextViewCell", owner: self, options: nil)!
                cell = nib.objectAtIndex(0) as? FeedbackTextViewCell
            }
            moreTextView = cell!.textView
            cell?.selectionStyle = .None
            
            if let text = feedBack?.boxMore {
                moreTextView.text = text
            }
            
            return cell!
            
        default:
            break
        }
        
        return tableView.dequeueReusableCellWithIdentifier("cell")!
    }
    
    private func isValidInput() -> Bool {
        if (qualityCell == nil || percentCell == nil) {return false;}
        
        return qualityCell!.qualitySegmentedControl.selectedSegmentIndex < Feedback.boxQualityOptions.count && qualityCell!.qualitySegmentedControl.selectedSegmentIndex >= 0
    }
    
    @IBAction func save(sender: AnyObject) {
        if let feedBack = feedBack {
            if (isValidInput()) {
                feedBack.percentOfBookUsed = round(percentCell!.percent * 100.0) / 100.0
                let qual = qualityCell!.qualitySegmentedControl.selectedSegmentIndex
                feedBack.boxQuality = Feedback.boxQualityOptions[qual]
                feedBack.boxMore = moreTextView.text
                feedBack.boxMissingItems = selectedItems
                self.navigationController?.popViewControllerAnimated(true)
            }else{
                // Something is wrong!
                SCLAlertView().showError("Invalid Input", subTitle: "It looks like you either did not fill in one of the values, or one of the values is invalid")
            }
        }
    }
    
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Amount of book used"
            
        case 1:
            return "Box"
            
        case 2:
            return "More"
            
        default:
            return ""
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 74
            
        case 1:
            return 50
    
        case 2:
            return 150
            
        default:
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if (indexPath.row == 1 && indexPath.section == 1) {
            self.performSegueWithIdentifier("showMissingItems", sender: nil)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let dest = segue.destinationViewController as? FeedbackMissingItemsViewController {
            dest.items = Feedback.boxMissingItemsOptions
            dest.selectedItems = self.selectedItems
            dest.finishedChoosing = {
                self.selectedItems = dest.selectedItems
            }
        }
    }
    
    @IBAction func hideKeyboard(sender: AnyObject) {
        moreTextView.resignFirstResponder()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
            
        case 1:
            return 2
            
        case 2:
            return 1
            
        default: return 0
        }
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
}
