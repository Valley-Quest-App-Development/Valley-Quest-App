//
//  FeedbackBoxViewController.swift
//  Valley Quest App
//
//  Created by John Kotz on 3/22/16.
//  Copyright © 2016 vitalCommunities. All rights reserved.
//

import Foundation

class FeedbackBoxViewController: UITableViewController {
    var moreTextView: UITextView = UITextView()
    var feedBack: Feedback?
    var percentCell: PercentCell?
    var qualityCell: QualityCell?
    
    override func viewDidLoad() {
        self.title = "Feedback - Box"
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
            cell.percent = 0.0
            return cell
            
        case 1:
            // Main box
            switch indexPath.row {
            case 0:
                if let qualityCell = qualityCell {
                    return qualityCell
                }
                let cell = tableView.dequeueReusableCellWithIdentifier("qualityCell") as! QualityCell
                qualityCell = cell
                cell.selectionStyle = .None
                return cell
                
            default:
                break
            }
            break
            
        case 2:
            // Other
            let cell = tableView.dequeueReusableCellWithIdentifier("cell")!
            cell.accessoryType = .DisclosureIndicator
            cell.selectionStyle = .Gray
            cell.textLabel?.text = "Missing Items"
            return cell
            
        case 3:
            // More
            var cell = tableView.dequeueReusableCellWithIdentifier("cell") as? FeedbackTextViewCell
            
            if cell == nil {
                let nib: NSArray = NSBundle.mainBundle().loadNibNamed("FeedbackTextViewCell", owner: self, options: nil)
                cell = nib.objectAtIndex(0) as? FeedbackTextViewCell
            }
            moreTextView = cell!.textView
            
            return cell!
            
        default:
            break
        }
        
        return tableView.dequeueReusableCellWithIdentifier("cell")!
    }
    
    @IBAction func save(sender: AnyObject) {
        if let feedBack = feedBack {
            feedBack.percentOfBookUsed = round(percentCell!.percent * 100.0) / 100.0
            feedBack.boxQuality = qualityCell!.qualitySegmentedControl.titleForSegmentAtIndex(qualityCell!.qualitySegmentedControl.selectedSegmentIndex)
            feedBack.boxMore = moreTextView.text
        }
    }
    
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Amount of book used"
            
        case 1:
            return "Box"
            
        case 2:
            return "Other"
            
        case 3:
            return "More"
            
        default:
            return ""
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 74
            
        case 1:
            return 44
        
        case 2:
            return 44
        
        case 3:
            return 150
            
        default:
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    @IBAction func hideKeyboard(sender: AnyObject) {
        moreTextView.resignFirstResponder()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
            
        case 1:
            return 1
            
        case 2:
            return 1
            
        case 3:
            return 1
            
        default: return 0
        }
    }
}