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

class PDFViewController: UIViewController, UIWebViewDelegate {
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
                    self.pdfView.delegate = self
                }
            }else{
                print("Error!! \(error)")
            }
        })
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        self.pdfView.scrollView.setContentOffset(CGPoint(x: 0, y: -(self.navigationController!.navigationBar.frame.height + 20)), animated: false)
    }
    
    func setObject(file: PFFile) {
        self.file = file
        updateView()
    }
    
}