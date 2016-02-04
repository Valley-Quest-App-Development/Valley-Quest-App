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
        }
    }
    
    func updateView() {
        file?.getFilePathInBackgroundWithBlock({ (path, error) -> Void in
            self.pdfView.loadRequest(NSURLRequest(URL: NSURL.fileURLWithPath(path!)))
        })
    }
    
    func setObject(file: PFFile) {
        self.file = file
        updateView()
    }
    
    
}