//
//  FeedbackCluesViewController.swift
//  Valley Quest App
//
//  Created by John Kotz on 3/22/16.
//  Copyright © 2016 vitalCommunities. All rights reserved.
//

import Foundation
import BEMCheckBox
import SCLAlertView

class FeedbackCluesViewController: UITableViewController {
    var accuracySeg: UISegmentedControl?
    var claritySeg: UISegmentedControl?
    var updatingCheck: BEMCheckBox?
    var moreText: UITextView?
    
    var feedBack: Feedback?
    
    override func viewDidLoad() {
        self.title = "Feedback - Clues"
    }
    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 3
        }else{
            return 1
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Clues"
        }else{
            return "More"
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 1 {
            return 150
        }
        
        return 44
    }
    
    private func isValidInput() -> Bool {
        if (accuracySeg == nil || claritySeg == nil || updatingCheck == nil) {return false}
        
        let accuracy = accuracySeg!.selectedSegmentIndex;
        let clarity = claritySeg!.selectedSegmentIndex;
        
        return accuracy >= 0 && clarity >= 0 && accuracy < Feedback.cluesAccuracyOptions.count && clarity < Feedback.clarityOptions.count
    }
    
    @IBAction func save(sender: AnyObject) {
        if let feedBack = feedBack {
            if (isValidInput()) {
                feedBack.addCluesFeedback(Feedback.cluesAccuracyOptions[accuracySeg!.selectedSegmentIndex], clarity: Feedback.clarityOptions[claritySeg!.selectedSegmentIndex], needUpdate: updatingCheck!.on, more: moreText!.text)
                self.navigationController?.popViewControllerAnimated(true)
            }else{
                // Something is wrong!
                SCLAlertView().showError("Invalid Input", subTitle: "It looks like you either did not fill in one of the values, or one of the values is invalid")
            }
        }
    }
    
    @IBAction func hideKeyboard(sender: AnyObject) {
        self.moreText?.resignFirstResponder()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true);
        if (indexPath.section == 0 && indexPath.row == 2) {
            updatingCheck?.setOn(!updatingCheck!.on, animated: true)
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 || indexPath.row == 1 {
                let cell: SegmentedCell = tableView.dequeueReusableCellWithIdentifier("SegmentedCell") as! SegmentedCell
                
                if indexPath.row == 0 {
                    cell.setTitle("Accuracy")
                    cell.setSegments(Feedback.cluesAccuracyOptions)
                    
                    accuracySeg = cell.segment
                    
                    if let accString = feedBack?.cluesAccuracy {
                        if let index = Feedback.cluesAccuracyOptions.indexOf(accString) {
                            accuracySeg?.selectedSegmentIndex = index
                        }
                    }
                }else {
                    cell.setTitle("Clarity")
                    cell.setSegments(Feedback.clarityOptions)
                    claritySeg = cell.segment
                    
                    if let clarString = feedBack?.clarity {
                        if let index = Feedback.clarityOptions.indexOf(clarString) {
                            claritySeg?.selectedSegmentIndex = index
                        }
                    }
                }
                
                cell.selectionStyle = .None
                
                return cell
            }else{
                let cell: CheckBoxCell = tableView.dequeueReusableCellWithIdentifier("checkBoxCell") as! CheckBoxCell
                
                cell.titleLabel.text = "Clues need updating"
                updatingCheck = cell.checkBox
                
                if let feedBack = feedBack {
                    updatingCheck?.setOn(feedBack.cluesNeedUpdate, animated: false)
                }
                
                return cell
            }
        }else{
            var cell = tableView.dequeueReusableCellWithIdentifier("cell") as? FeedbackTextViewCell
            
            if cell == nil {
                let nib: NSArray = NSBundle.mainBundle().loadNibNamed("FeedbackTextViewCell", owner: self, options: nil)
                cell = nib.objectAtIndex(0) as? FeedbackTextViewCell
            }
            cell?.selectionStyle = .None
            moreText = cell?.textView
            
            if let moreString = feedBack?.cluesMore {
                moreText?.text = moreString
            }
            
            return cell!
        }
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
}