//
//  PlaceholderViewController.swift
//  Valley Quest App
//
//  Created by John Kotz on 4/27/16.
//  Copyright © 2016 vitalCommunities. All rights reserved.
//

import Foundation
import UIKit
import MessageUI

class PlaceholderViewController: UIViewController, MFMailComposeViewControllerDelegate {
    @IBOutlet weak var feedbackButton: UIButton!
    
    @IBAction func sendFeedback(sender: UIButton) {
        sender.enabled = false
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.presentViewController(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        mailComposerVC.setToRecipients(["valleyquest@vitalcommunities.org", "John.P.Kotz.19@Dartmouth.edu"])
        mailComposerVC.setSubject("Valley Quest App Feedback")
        mailComposerVC.setMessageBody("", isHTML: false)
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertController(title: "Could not send email!", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", preferredStyle: .Alert)
        
        sendMailErrorAlert.addAction(UIAlertAction(title: "Okay", style: .Cancel, handler: { (_) in
            self.feedbackButton.enabled = true
        }))
        
        self.presentViewController(sendMailErrorAlert, animated: true, completion: nil)
    }
    
    // MARK: MFMailComposeViewControllerDelegate
    
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        controller.dismissViewControllerAnimated(true, completion: nil)
        feedbackButton.enabled = true;
        
    }
}