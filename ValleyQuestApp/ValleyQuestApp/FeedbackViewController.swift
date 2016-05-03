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
    @IBOutlet weak var submitButton: UIButton!
    
    override func viewDidLoad() {
        assert(quest != nil, "Given quest must be a quest")
        feedbackObject.forQuest = quest!
        let tap = UITapGestureRecognizer(target: self, action: #selector(FeedbackViewController.hideKeyboard))
        tap.cancelsTouchesInView = false
        self.tableView.addGestureRecognizer(tap)
        self.title = "Feedback"
    }
    
    override func viewWillAppear(animated: Bool) {
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.view.removeGestureRecognizer(self.revealViewController().panGestureRecognizer())
    }
    
    func hideKeyboard() {
        messageTextView.resignFirstResponder()
        emailTextField.resignFirstResponder()
    }
    
    @IBAction func submit(sender: UIButton) {
        feedbackObject.message = messageTextView.text!
        feedbackObject.submitterEmail = emailTextField.text!
        if feedbackObject.isValid() {
            feedbackObject.saveInBackground()
            self.navigationController?.popViewControllerAnimated(true)
        }else{
            let alert = UIAlertController(title: "Something is wrong", message: "Something with the inputs was wrong", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .Cancel, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destination = segue.destinationViewController as? FeedbackBoxViewController {
            destination.feedBack = self.feedbackObject
        }else if let destination = segue.destinationViewController as? FeedbackCluesViewController {
            destination.feedBack = self.feedbackObject
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
            // it was the second section. Now we just need to open the other views
            switch  indexPath.row {
            case 0:
                self.performSegueWithIdentifier("boxFeedbackView", sender: nil)
                break
            case 1:
                self.performSegueWithIdentifier("cluesFeedbackView", sender: nil)
                break
            default:
                // This is not one of the cells I remember!
                break
            }
            
            
            break
            
        default:
            tableView.deselectRowAtIndexPath(indexPath, animated: false)
            break
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