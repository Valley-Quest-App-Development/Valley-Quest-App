//
//  DirectionsViewController.swift
//  Valley Quest App
//
//  Created by John Kotz on 3/20/16.
//  Copyright © 2016 vitalCommunities. All rights reserved.
//

import Foundation
import MapKit

class DirectionsViewController: UIViewController {
    @IBOutlet weak var openInMapsButton: UIButton!
    @IBOutlet weak var label: UILabel!
    
    var text: String?
    var coords: CLLocationCoordinate2D?
    var name: String?
    
    func setThings(text: String, coords: CLLocationCoordinate2D?, name: String) {
        self.text = text
        self.coords = coords
        self.name = name
        if label != nil {
            reload()
        }
    }
    
    override func viewDidLoad() {
        self.title = name
        reload()
    }
    
    func reload() {
        if let text = self.text {
            if let label = self.label {
                print(text);
                let paragraphStyle = NSMutableParagraphStyle()
                
                if (UIDevice.currentDevice().userInterfaceIdiom == .Pad) {
                    paragraphStyle.lineSpacing = 30
                }else{
                    paragraphStyle.maximumLineHeight = 20
                    paragraphStyle.minimumLineHeight = 5
                }
                
                paragraphStyle.alignment = NSTextAlignment.Center
                
                let attrString = NSMutableAttributedString(string: text)
                attrString.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, attrString.length))
                
                label.attributedText = attrString
            }
            if coords == nil {
                openInMapsButton.hidden = true
                openInMapsButton.enabled = false
            }
        }
    }
    
    @IBAction func openInMaps(sender: AnyObject) {
        if let coords = coords, let name = name {
            HelperMethods.openLocation(coords, name: name)
        }
    }
    
    @IBAction func hide(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
}