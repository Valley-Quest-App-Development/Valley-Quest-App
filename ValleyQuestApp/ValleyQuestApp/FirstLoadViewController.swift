//
//  FirstLoadViewController.swift
//  Valley Quest App
//
//  Created by John Kotz on 5/11/16.
//  Copyright © 2016 vitalCommunities. All rights reserved.
//

import Foundation
import UIKit

let welcomeMessage = "We are so excited that you are beta testing the Valley Quest App. The testing process for this app will provide vital information on how to improve the app and get it to where it deserves to be."

class FirstLoadViewController: UIViewController {
    @IBOutlet weak var text: UILabel!
    @IBOutlet weak var goButton: UIButton!
    
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
        self.text.font = UIFont.systemFontOfSize(22)
        
        if (UIDevice.currentDevice().userInterfaceIdiom == .Pad) {
            self.text.font = UIFont.systemFontOfSize(35)
            self.goButton.titleLabel?.font = UIFont.systemFontOfSize(40)
        }
    }
    
    @IBAction func dismiss(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}