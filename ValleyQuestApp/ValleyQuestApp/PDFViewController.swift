//
//  PDFViewer.swift
//  ValleyQuestApp
//
//  Created by John Kotz on 2/2/16.
//  Copyright © 2016 John Kotz. All rights reserved.
//

import Foundation
import UIKit
import Parse

class PDFViewController: UIViewController {
    @IBOutlet weak var pdfView: UIWebView!
    
    var file: PFFile?
    
    override func viewDidLoad() {
        if file != nil {
            updateView()
            self.pdfView.scalesPageToFit = true
        }
    }
    
    func updateView() {
        file?.getFilePathInBackgroundWithBlock({ (path, error) -> Void in
            if let checkedPath = path {
                if self.pdfView != nil {
                    self.pdfView.loadRequest(NSURLRequest(URL: NSURL.fileURLWithPath(checkedPath)))
                }
            }else{
                print("Error!! \(error)")
            }
        })
    }
    
    func setObject(file: PFFile) {
        self.file = file
        updateView()
    }
    
    
}