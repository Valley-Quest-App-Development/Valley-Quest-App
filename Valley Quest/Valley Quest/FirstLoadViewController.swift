//
//  FirstLoadViewController.swift
//  Valley Quest App
//
//  Created by John Kotz on 5/11/16.
//  Copyright © 2016 vitalCommunities. All rights reserved.
//

import Foundation
import UIKit
import MessageUI
import SCLAlertView

let welcomeMessage = "We are so excited that you are using the Valley Quest App. In the app you can see all the quests currently offered, find the most recent data about corrections, and even save quests for offline access, and even more features are coming very soon! We try our best to keep all the data up to date, but if you find any problems with the data let us know."

class FirstLoadViewController: UIViewController, MFMailComposeViewControllerDelegate {
    @IBOutlet weak var text: UILabel!
    @IBOutlet weak var goButton: UIButton!
    var goString: String?
    
    override func viewDidLoad() {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5
        if (UIDevice.currentDevice().userInterfaceIdiom == .Pad) {
            paragraphStyle.lineSpacing = 15
        }
        
        let attrString = NSMutableAttributedString(string: welcomeMessage)
        attrString.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, attrString.length))
        
        self.text.attributedText = attrString
        self.text.textAlignment = .Center
        self.text.font = UIFont.systemFontOfSize(15)
        if let goString = goString {
            self.goButton.setTitle(goString, forState: .Normal)
        }
        
        if (UIDevice.currentDevice().userInterfaceIdiom == .Pad) {
            self.text.font = UIFont.systemFontOfSize(25)
            self.goButton.titleLabel?.font = UIFont.systemFontOfSize(30)
        }
    }
    
    @IBAction func dismiss(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
        
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "hasLaunched")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    @IBAction func contact(sender: AnyObject) {
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.presentViewController(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
    }
    
    @IBAction func donate(sender: AnyObject) {
        if let url = NSURL(string: "https://www.networkforgood.org/donation/ExpressDonation.aspx?ORGID2=030355283&vlrStratCode=sZOvB%2f0cd%2fdoiEayuvrC00Wpqg5KQXiMKCNvYiEF8abJeD1aG8utwd4qpQEAinGo") {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        mailComposerVC.setToRecipients(["valleyquest@vitalcommunities.org", "John.P.Kotz.19@Dartmouth.edu"])
        mailComposerVC.setSubject("")
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        SCLAlertView().showError("Could not send email!", subTitle: "Your device could not send email.  Please check email configuration and try again")
    }
    
    // MARK: MFMailComposeViewControllerDelegate
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
        if result == MFMailComposeResultSent {
//            SCLAlertView().showSuccess("Thank you", subTitle: "")
        }else{
            showSendMailErrorAlert()
        }
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
}