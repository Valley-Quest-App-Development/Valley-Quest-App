//
//  DirectionsViewController.swift
//  Valley Quest App
//
//  Created by John Kotz on 3/20/16.
//  Copyright © 2016 vitalCommunities. All rights reserved.
//

import Foundation

class DirectionsViewController: UIViewController {
    @IBOutlet weak var openInMapsButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    
    var text: String?
    var coords: CLLocationCoordinate2D?
    var name: String?
    
    func setThings(text: String, coords: CLLocationCoordinate2D?, name: String) {
        self.text = text
        self.coords = coords
        self.name = name
        if textView != nil {
            reload()
        }
    }
    
    override func viewDidLoad() {
        self.title = name
        reload()
    }
    
    func reload() {
        if let text = self.text {
            if let textView = self.textView {
                let style = NSMutableParagraphStyle()
                style.lineSpacing = 20
                let atributes = [NSParagraphStyleAttributeName : style]
                textView.attributedText = NSAttributedString(string: text, attributes: atributes)
                
                textView.font = UIFont.systemFontOfSize(15)
                textView.textAlignment = .Center
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