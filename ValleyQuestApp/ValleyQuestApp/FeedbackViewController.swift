//
//  FeedbackViewController.swift
//  Valley Quest App
//
//  Created by John Kotz on 3/22/16.
//  Copyright © 2016 vitalCommunities. All rights reserved.
//

import Foundation


class FeedbackViewController: UITableViewController {
    
    var feedbackObject: Feedback = Feedback()
    var quest: Quest?
    var messageTextView: UITextView = UITextView()
    var emailTextField = UITextField()
    
    override func viewDidLoad() {
        assert(quest != nil, "Given quest must be a quest")
        feedbackObject.forQuest = quest!
        let tap = UITapGestureRecognizer(target: self, action: #selector(FeedbackViewController.hideKeyboard))
        tap.cancelsTouchesInView = false
        self.tableView.addGestureRecognizer(tap)
        self.title = "Send Feedback"
    }
    
    func hideKeyboard() {
        messageTextView.resignFirstResponder()
        emailTextField.resignFirstResponder()
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            // It it is the first one, then it must be the message cell
            if indexPath.row == 0 {
                var cell = tableView.dequeueReusableCellWithIdentifier("cell") as? FeedbackTextViewCell
                
                if cell == nil {
                    let nib: NSArray = NSBundle.mainBundle().loadNibNamed("FeedbackTextViewCell", owner: self, options: nil)
                    cell = nib.objectAtIndex(0) as? FeedbackTextViewCell
                }
                self.messageTextView = cell!.textView
                
                cell!.selectionStyle = .None
                return cell!
            }else{
                let cell = tableView.dequeueReusableCellWithIdentifier("emailCell") as! FeedbackInputCell
                self.emailTextField = cell.textFeild
                cell.selectionStyle = .None
                return cell
            }
            
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("cell")!
            if indexPath.row == 0 {
                cell.textLabel?.text = "Box"
            }else if indexPath.row == 1 {
                cell.textLabel?.text = "Clues"
            }
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            cell.selectionStyle = .Gray
            return cell
            
        default:
            return tableView.dequeueReusableCellWithIdentifier("cell")!
        }
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        self.hideKeyboard()
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 0 {
            return 150
        }else{
            return 50
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Message"
        }else if section == 1 {
            return "Other"
        }else{
            return ""
        }
    }
    
    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Enter your email so we can contact you if we have questions"
        case 1:
            return "If you want to be more specific you can use these features to make processing it easyer and more efficient"
        default:
            return ""
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.section {
        case 1:
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            break
            
        default: break
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 2
            
        case 1:
            return 2
            
        default:
            return 0
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
}